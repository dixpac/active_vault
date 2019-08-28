# frozen_string_literal: true

module ActiveVault
  # Figures out encryption key for the record. If record already has a
  # encryption key, decrypts it with +ActiveVault::Service+ and returns key.
  # If there is no key present it generates new radnom 32-bytes long key.
  class EncryptionKey
    attr_reader :model

    def self.for(model)
      new(model).plaintext
    end

    def initialize(model)
      @model = model
    end

    def plaintext
      if model.encrypted_key
        ActiveVault.service.decrypt(model.encrypted_key)
      else
        generate_random_key
      end
    end

    private
      # Generates random 32-bytes long key that will encrypt/decrypt
      # attributes. Each db record gets it's own key.
      # This key is then encrypted with KMS and stored inside `encrypted_key`
      # column.
      #
      # Key must be 32-bytes long since aes-256-gcm requires key that
      # length.
      def generate_random_key
        SecureRandom.random_bytes(32)
      end
  end
end
