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
    return false unless signature && certificates.any?
    return false unless certificate_valid?
    return false unless domains_match?
  
    verify_signature
  rescue OpenSSL::OpenSSLError => e
    Rails.logger.error "Signature verification error: #{e.message}"
    false
  end  

  def verify_signature
    case public_key
    when OpenSSL::PKey::RSA
      public_key.verify(digest, signature, canonical_message)
    when OpenSSL::PKey::DSA
      public_key.sysverify(digest.digest(canonical_message), signature)
    when OpenSSL::PKey::EC
      public_key.dsa_verify_asn1(digest.digest(canonical_message), signature)
    else
      Rails.logger.error "Unsupported public key type: #{public_key.class}"
      return false
    end
  end

  private

  def signature
    @signature ||= Base64.strict_decode64(@signature_base64)
  rescue ArgumentError => e
    Rails.logger.error "Invalid Base64 signature: #{e.message}"
    nil
  end

  def public_key
    end_entity_cert.public_key
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
      store.add_cert(end_entity_cert)
    else
      store.set_default_paths

      certificates[1..-1].each do |cert|
        store.add_cert(cert)
      end
    end

    store_context = OpenSSL::X509::StoreContext.new(store, end_entity_cert)

    store_context.verify
  end

  def certificates
    @certificates ||= load_certificates(@certificate_pem)
  end
  
  def end_entity_cert
    @end_entity_cert ||= certificates.first
  end

  def load_certificates(pem_data)
    pem_certs = pem_data.scan(/-----BEGIN CERTIFICATE-----(.*?)-----END CERTIFICATE-----/m)

    pem_certs.map do |cert_pem|
      OpenSSL::X509::Certificate.new("-----BEGIN CERTIFICATE-----#{cert_pem.first}-----END CERTIFICATE-----")
    end
  end

  def extract_domains_from_certificate(certificate)
    domains = []
  
    cn_entry = certificate.subject.to_a.find { |name, _, _| name == 'CN' }
  
    if cn_entry
      cn = cn_entry[1].downcase

      domains << cn
    else
      Rails.logger.warn "Certificate does not contain a Common Name (CN)."
    end
  
    san_extension = certificate.extensions.find { |ext| ext.oid == 'subjectAltName' }

    if san_extension
      san         = san_extension.value
      san_domains = san.scan(/DNS:([^\s,]+)(?:,|$)/i).flatten

      domains.concat(san_domains.map(&:downcase))
    else
      Rails.logger.warn "Certificate does not contain a Subject Alternative Name (SAN) extension."
    end
  
    domains.uniq
  end

  def domains_match?
    domains = extract_domains_from_certificate(end_entity_cert)
    
    domains.include?(@expected_domain)
  end

end