require 'openssl'
require 'base64'

class SignatureVerifier

  def initialize(message_data:, signature_base64:, certificate_pem:, expected_domain:)
    @message_data     = message_data
    @signature_base64 = signature_base64
    @certificate_pem  = certificate_pem
    @expected_domain  = expected_domain
  end

  def verify
    return false unless signature && certificate
    return false unless certificate_valid?
    return false unless domain_matches_certificate?

    public_key.verify(digest, signature, canonical_message)
  rescue OpenSSL::OpenSSLError => e
    Rails.logger.error "Signature verification error: #{e.message}"
    false
  end

  private

  def signature
    @signature ||= Base64.strict_decode64(@signature_base64)
  rescue ArgumentError => e
    Rails.logger.error "Invalid Base64 signature: #{e.message}"
    nil
  end

  def certificate
    @certificate ||= OpenSSL::X509::Certificate.new(@certificate_pem)
  rescue OpenSSL::X509::CertificateError => e
    Rails.logger.error "Invalid certificate: #{e.message}"
    nil
  end

  def public_key
    certificate.public_key
  end

  def digest
    OpenSSL::Digest::SHA256.new
  end

  def canonical_message
    JSON.generate(@message_data.sort.to_h)
  end

  def certificate_valid?
    store = OpenSSL::X509::Store.new

    if Rails.env.development?
      store.add_cert(certificate)
    else
      store.set_default_paths
    end

    store.verify(certificate)
  end

  def domain_matches_certificate?
    cert_domains = []

    cert_cn = extract_cn(certificate.subject.to_s)

    cert_domains << cert_cn if cert_cn

    san_extension = certificate.extensions.find { |ext| ext.oid == 'subjectAltName' }
  
    if san_extension
      san_domains = san_extension.value.scan(/DNS:([^\s,]+)/).flatten
      cert_domains.concat(san_domains)
    end

    cert_domains.any? do |cert_domain|
      cert_domain && @expected_domain && cert_domain.casecmp(@expected_domain)&.zero?
    end
  end

  def extract_cn(subject)
    if subject =~ /\/CN=([^\/]+)/
      return $1
    else
      return nil
    end
  end

end