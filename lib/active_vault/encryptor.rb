# frozen_string_literal: true

module ActiveVault
  # Wraps +ActiveSupport::MessageEncryptor+ to provide encryption and decryption
  # of the data.
  class Encryptor
    def initialize(key)
      @key = key
    end

    # Returns Base64 encoded encrypted_data. encrypted_data is combination of
    # salt + encrypted value. Salt is stored togeather wit the data so we can
    # decrypt.
    def encrypt(value)
      salt  = SecureRandom.random_bytes(key_length)
      key   = ActiveSupport::KeyGenerator.new(@key).generate_key(salt, key_length)
      crypt = ActiveSupport::MessageEncryptor.new(key)

      encrypted_data = crypt.encrypt_and_sign(value)
      Base64.strict_encode64(salt + encrypted_data)
    end

    # Returns decrypted value.
    def decrypt(encrypted_data)
      encrypted_data = Base64.strict_decode64(encrypted_data)
      salt, encrypted_data = extract_salt(encrypted_data)
      key   = ActiveSupport::KeyGenerator.new(@key).generate_key(salt, key_length)
      crypt = ActiveSupport::MessageEncryptor.new(key)

      crypt.decrypt_and_verify(encrypted_data)
    end

    private
      # Extract sault from the encrypted data, so we can decrypt.
      def extract_salt(encrypted_data)
        salt = encrypted_data.slice(0, key_length)
        [salt, encrypted_data.slice(key_length..-1)]
      end


      def key_length
        @_key_length ||= ActiveSupport::MessageEncryptor.key_len
      end
  end
end
