require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)
require "active_encryption"

module Dummy
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    config.active_encryption.service = :local
  end
end

