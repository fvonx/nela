require 'net/http'

class SecureRequestSender

  HTTP_METHODS = {
    'GET'     => Net::HTTP::Get,
    'POST'    => Net::HTTP::Post,
    'PUT'     => Net::HTTP::Put,
    'DELETE'  => Net::HTTP::Delete,
    'PATCH'   => Net::HTTP::Patch,
    'HEAD'    => Net::HTTP::Head,
    'OPTIONS' => Net::HTTP::Options,
    'TRACE'   => Net::HTTP::Trace,
  }.freeze

  def initialize(http_method = "POST", uri, message_data)
    @uri          = URI.parse(uri)
    @message_data = message_data
    @http_method  = http_method
  end

  def send_request
    setup_http_client

    request_class = HTTP_METHODS[@http_method]
    raise "Unsupported HTTP method: #{@http_method}" unless request_class

    request = request_class.new(@uri.request_uri)
    request['Content-Type'] = 'application/json'

    sign_message

    payload = {
      message: @message_data
    }.merge(@signature_info)

    if ['POST', 'PUT', 'PATCH'].include?(@http_method)
      request.body = payload.to_json
    end

    response = @http.request(request)

    handle_response(response)
  rescue StandardError => e
    handle_error(e)
  end

  private

  def setup_http_client
    @http         = Net::HTTP.new(@uri.host, @uri.port)
    @http.use_ssl = true
  
    SslConfiguration.setup_http_client(@http)
  
    @http.open_timeout = 5
    @http.read_timeout = 10
  end

  def sign_message
    signer = MessageSigner.new(
      message_data:     @message_data,
      private_key_path: SecureConfiguration.private_key_path,
      certificate_path: SecureConfiguration.certificate_path
    )

    @signature_info = signer.sign
  end

  def handle_response(response)
    if response.is_a?(Net::HTTPSuccess)
      success_message = "Request to #{@uri} was successful."

      Rails.logger.info success_message
  
      { success: true, message: success_message, response: response }
    else
      error_message = "Request to #{@uri} failed. Response: #{response.body}"

      Rails.logger.error error_message

      { success: false, message: error_message, response: response }
    end
  end

  def handle_error(exception)
    error_message = "Error sending request to #{@uri}: #{exception.message}"

    Rails.logger.error error_message

    { success: false, message: error_message }
  end

end