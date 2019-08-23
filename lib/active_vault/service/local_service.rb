# frozen_string_literal: true

module ActiveVault
  # Local simulation of KMS. This is not secure implementation and for know it's
  # here only so we can test easilly.
  #
  # TODO: Research and implement better locale version.
  class Service::LocalService < Service
    PREFIX = Base64.decode64("insecure+locale+A")

    def initialize(key:)
      @key = key
    end

    def encrypt(plaintext)
      parts = [PREFIX, Base64.strict_encode64(plaintext)]
      parts.join(":")
    end

    def decrypt(ciphertext)
      prefix, plaintext = ciphertext.split(":")
      decode64(plaintext)
    end
  end
end
