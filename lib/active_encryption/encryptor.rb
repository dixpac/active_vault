# frozen_string_literal: true

module ActiveEncryption
  class DecryptionError < StandardError; end

  class Encryptor
    def initialize(key)
      @key = key
    end

    def encrypt(message)
      cipher = OpenSSL::Cipher.new("aes-256-gcm")
      cipher.encrypt
      cipher.key = @key
      cipher.iv = nonce
      cipher.auth_data = ""

      ciphertext = cipher.update(message) + cipher.final
      ciphertext << cipher.auth_tag

      ciphertext
    end

    def decrypt(ciphertext)
      auth_tag, ciphertext = extract_auth_tag(ciphertext.to_s)

      fail_decryption if nonce.to_s.bytesize != nonce_bytes
      fail_decryption if auth_tag.to_s.bytesize != auth_tag_bytes
      fail_decryption if ciphertext.to_s.bytesize == 0

      cipher.decrypt
      cipher.key = @key
      cipher.iv = nonce
      cipher.auth_tag = auth_tag
      cipher.auth_data = ""

      begin
        cipher.update(ciphertext) + cipher.final
      rescue OpenSSL::Cipher::CipherError
        raise DecryptionError, "Decryption failed"
      end
    end

    private
   #   def cipher
   #     OpenSSL::Cipher.new("aes-256-gcm")
   #   end

      def nonce
        SecureRandom.random_bytes(nonce_bytes)
      end

      def nonce_bytes
        12
      end

      def extract_auth_tag(bytes)
        auth_tag = bytes.slice(-auth_tag_bytes..-1)
        [auth_tag, bytes.slice(0, bytes.bytesize - auth_tag_bytes)]
      end
  end
end
