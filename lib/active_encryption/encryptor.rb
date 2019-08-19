# frozen_string_literal: true

module ActiveEncryption
  class DecryptionError < StandardError; end

  class Encryptor
    def initialize(key)
      raise ArgumentError, "Key must be 32 bytes" unless key && key.bytesize == 32
      raise ArgumentError, "Key must be binary" unless key.encoding == Encoding::BINARY

      @key = key
    end

    def encrypt(message)
      nonce = generate_nonce
      cipher = OpenSSL::Cipher.new("aes-256-gcm")
      cipher.encrypt
      cipher.key = @key
      cipher.iv = nonce
      cipher.auth_data = ""

      ciphertext = cipher.update(message) + cipher.final
      ciphertext << cipher.auth_tag

      Base64.strict_encode64(nonce + ciphertext)
    end

    def decrypt(ciphertext)
      ciphertext = Base64.decode64(ciphertext)
      nonce, ciphertext = extract_nonce(ciphertext)
      auth_tag, ciphertext = extract_auth_tag(ciphertext.to_s)

      fail_decryption if nonce.to_s.bytesize != nonce_bytes
      fail_decryption if auth_tag.to_s.bytesize != auth_tag_bytes
      fail_decryption if ciphertext.to_s.bytesize == 0

      cipher = OpenSSL::Cipher.new("aes-256-gcm")
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
      def generate_nonce
        SecureRandom.random_bytes(nonce_bytes)
      end

      def extract_nonce(ciphertext)
        nonce = ciphertext.slice(0, nonce_bytes)
        [nonce, ciphertext.slice(nonce_bytes..-1)]
      end

      def nonce_bytes
        12
      end

      def auth_tag_bytes
        16
      end

      def extract_auth_tag(bytes)
        auth_tag = bytes.slice(-auth_tag_bytes..-1)
        [auth_tag, bytes.slice(0, bytes.bytesize - auth_tag_bytes)]
      end
  end
end
