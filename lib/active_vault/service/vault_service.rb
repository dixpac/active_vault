# frozen_string_literal: true

require "vault"

module ActiveVault
  # Wraps the Hashicorp Vault as an Active Vault service.
  # See ActiveVault::Service for the generic API documentation that applies to all services.
  class Service::VaultService < Service
    attr_reader :key_id, :address, :token

    def initialize(key_id:, address:, token:)
      @key_id  = key_id
      @address = address
      @token   = token
    end

    def encrypt(value)
      options = { plaintext: encode64(value) }

      response = client.logical.write(path, options)
      encrypted_data = response.data[:ciphertext]

      encode64(encrypted_data)
    end

    def decrypt(encrypted_data)
      options = { ciphertext: decode64(encrypted_data) }

      response =
        begin
          client.logical.write(path, options)
        rescue ::Vault::HTTPClientError => e
          decryption_failed! if e.message.include?("unable to decrypt")
          raise e
        rescue Encoding::UndefinedConversionError
          decryption_failed!
        end

      decode64(response.data[:plaintext])
    end

    private
      def client
        @_client ||= Vault::Client.new(address: address, token: token)
      end

      def path
        "transit/encrypt/#{key_id.sub("vault/", "")}"
      end
  end
end
