# frozen_string_literal: true

module ActiveVault
  # Abstract class serving as an interface for concrete services.
  #
  # The available services are:
  #
  # * +AWS+, to manage keys through Amazon KMS.
  #
  # Inside a Rails application, you can set-up your services through the
  # generated <tt>config/vault.yml</tt> file and reference one
  # of the aforementioned constant under the +service+ key. For example:
  #
  #   local:
  #     service: AWS
  #     key_id: "..."
  #     access_key: "..."
  #     secret_access: "..."
  #
  # You can checkout the service's constructor to know which keys are required.
  #
  # Then, in your application's configuration, you can specify the service to
  # use like this:
  #
  #   config.active_vault.service = :local
  class Service
    extend ActiveSupport::Autoload
    autoload :Configurator

    class << self
      # Configure an Active Vault service by name from a set of configurations,
      # typically loaded from a YAML file. The Active Vault engine uses this
      # to set the global Active Vault service when the app boots.
      def configure(service_name, configurations)
        Configurator.build(service_name, configurations)
      end

      # Override in subclasses that stitch together multiple services and hence
      # need to build additional services using the configurator.
      #
      # Passes the configurator and all of the service's config as keyword args.
      def build(configurator:, service: nil, **service_config)
        new(**service_config)
      end

      # Encrypts +plaintext+ with configured Service and returns cihpertext.
      def encrypt(plaintext)
        raise NotImplementedError
      end

      # Decrypts +ciphertext+ with configured Service and returns plaintext.
      def decrypt(ciphertext)
        raise NotImplementedError
      end
    end

    private
      def encode64(bytes)
        Base64.strict_encode64(bytes)
      end

      def decode64(bytes)
        Base64.decode64(bytes)
      end
  end
end
