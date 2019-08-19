require "active_record"
require "active_support"
require "active_support/rails"

require "active_encryption/version"
require "active_encryption/errors"
require "active_encryption/railtie"


module ActiveEncryption
  extend ActiveSupport::Autoload

  autoload :KeyGenerator
  autoload :Cipher
  autoload :Service

  mattr_accessor :service
end
