require 'openssl'
require 'base64'

class MessageSigner

  def initialize(message_data:, private_key_path:, certificate_path:)
    @message_data     = message_data
    @private_key_path = private_key_path
    @certificate_path = certificate_path
  end

  def sign
    {
      signature:   signature_base64,
      certificate: certificate_pem
    }
  end

  private

  def private_key
    @private_key ||= OpenSSL::PKey::RSA.new(File.read(@private_key_path))
  end

  def certificate_pem
    @certificate_pem ||= File.read(@certificate_path)
  end

  def canonical_message
    JSON.generate(@message_data.sort.to_h)
  end

  def signature
    private_key.sign(digest, canonical_message)
  end

  def signature_base64
    Base64.strict_encode64(signature)
  end

  def digest
    OpenSSL::Digest::SHA256.new
  end

end