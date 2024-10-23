module SecureConfiguration

  def self.private_key_path
    ENV['PRIVATE_KEY_PATH'] || Rails.root.join('config', 'ssl', 'dev_privkey.pem').to_s
  end

  def self.certificate_path
    ENV['CERTIFICATE_PATH'] || Rails.root.join('config', 'ssl', 'dev_cert.pem').to_s
  end

end