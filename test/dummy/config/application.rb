require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)
require "active_vault"

module Dummy
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    #config.active_vault.service = :local
    config.active_vault.service = :aws
  end
end

