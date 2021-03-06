# frozen_string_literal: true

require "active_record"
require "active_support"
require "active_support/rails"

require "active_vault/version"
require "active_vault/errors"
require "active_vault/railtie"


module ActiveVault
  extend ActiveSupport::Autoload

  autoload :EncryptionKey
  autoload :Encryptor
  autoload :Service

  mattr_accessor :service
end
