require_relative "boot"

require "rails"

require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)

module Nela

  class Application < Rails::Application

    config.load_defaults 7.2

    config.autoload_lib(ignore: %w[assets tasks])

    # config.time_zone = "Central Time (US & Canada)"

    config.eager_load_paths << Rails.root.join('app', 'services')
    config.eager_load_paths << Rails.root.join('app', 'validators')
    config.eager_load_paths << Rails.root.join('app', 'form_builders')

    config.generators.system_tests = nil

    config.nela = ActiveSupport::OrderedOptions.new

  end

end
