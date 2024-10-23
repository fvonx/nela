require "active_support/core_ext/integer/time"

Rails.application.configure do

  config.enable_reloading                  = false
  config.eager_load                        = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # config.require_master_key         = true
  # config.public_file_server.enabled = false
  # config.assets.css_compressor      = :sass

  config.assets.compile = false

  # config.asset_host                        = "http://assets.example.com"
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for Apache
  # config.action_dispatch.x_sendfile_header = "X-Accel-Redirect" # for NGINX

  config.active_storage.service = :local

  # config.action_cable.mount_path              = nil
  # config.action_cable.url                     = "wss://example.com/cable"
  # config.action_cable.allowed_request_origins = [ "http://example.com", /http:\/\/example.*/ ]
  # config.assume_ssl                           = true
  
  config.force_ssl = true
  
  # config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  config.logger = ActiveSupport::Logger.new(STDOUT)
    .tap  { |logger| logger.formatter = ::Logger::Formatter.new }
    .then { |logger| ActiveSupport::TaggedLogging.new(logger) }

  config.log_tags = [ :request_id ]  
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # config.cache_store                  = :mem_cache_store
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = "nela_production"

  config.action_mailer.perform_caching = false

  # config.action_mailer.raise_delivery_errors = false

  config.i18n.fallbacks                            = true
  config.active_support.report_deprecations        = false
  config.active_record.dump_schema_after_migration = false

  # config.hosts = [
  #   "example.com",     # Allow requests from example.com
  #   /.*\.example\.com/ # Allow requests from subdomains like `www.example.com`
  # ]

  # config.host_authorization = { exclude: ->(request) { request.path == "/up" } }

  # Nela Configuration

  config.nela.domain = "withnela.com"
  config.nela.ssl_verify_mode = OpenSSL::SSL::VERIFY_PEER

end
