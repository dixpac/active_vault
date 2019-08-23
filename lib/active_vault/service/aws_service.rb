# frozen_string_literal: true

require "aws-sdk-kms"

module ActiveVault
  # Wraps the Amazon Key Management Store(KMS) as an Active Vault service.
  # See ActiveVault::Service for the generic API documentation that applies to all services.
  class Service::AwsService < Service
    attr_reader :key_id, :access_key, :secret_access

    def initialize(key_id:, access_key:, secret_access:)
      @key_id       = key_id
      @access_key   = access_key
      @secret_access   = secret_access
    end

    def encrypt(plaintext)
      options = {
        key_id: key_id,
        plaintext: Base64.encode64(plaintext)
      }

      ciphertext = client.encrypt(options).ciphertext_blob

      "v#{1}:#{encode64(ciphertext)}"
    end

    def decrypt(ciphertext)
      m = /\Av(\d+):/.match(ciphertext)
      version = m[1].to_i
      ciphertext = ciphertext.sub("v#{version}:", "")
      ciphertext = decode64(ciphertext)


      options = { ciphertext_blob: ciphertext }

      response =
        begin
          client.decrypt(options).plaintext
        rescue ::Aws::KMS::Errors::InvalidCiphertextException
          decryption_failed!
        end

      decode64(response)
    end

    private
      def client
        @_client ||= Aws::KMS::Client.new(
          region: "eu-west-1",
          access_key_id: access_key,
          secret_access_key: secret_access,
          retry_limit: 1,
          http_open_timeout: 2,
          http_read_timeout: 2
        )
      end
  end
end
