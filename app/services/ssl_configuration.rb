module SslConfiguration

  def self.setup_http_client(http)
    http.verify_mode = Rails.configuration.nela.ssl_verify_mode
  end

end