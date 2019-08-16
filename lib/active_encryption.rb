require "openssl"
require "securerandom"

require "active_encryption/key_generator"
require "active_encryption/encryptor"
require "active_encryption/version"

require "active_encryption/railtie"


module ActiveEncryption
  extend ActiveSupport::Autoload

  autoload :Service

  mattr_accessor :service
end
