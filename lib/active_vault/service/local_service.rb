# frozen_string_literal: true

module ActiveVault
  # Local simulation of KMS. This is not secure implementation and for know it's
  # here only so we can test easilly.
  #
  # TODO: Research and implement better locale version.
  class Service::LocalService < Service
    def initialize(key:)
      @key = key
    end

    def encrypt(plaintext)
      Base64.strict_encode64(plaintext)
    end

    def decrypt(ciphertext)
      decode64(ciphertext)
    end
  end
end
