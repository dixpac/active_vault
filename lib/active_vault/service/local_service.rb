# frozen_string_literal: true

module ActiveVault
  # Local simulation of KMS. This is not secure implementation and for know it's
  # here only so we can test easilly.
  #
  # TODO: Research and implement better locale version.
  class Service::LocalService < Service
    attr_reader :master_key

    def initialize(master_key:)
      @master_key = master_key
    end

    def encrypt(value)
      ActiveVault::Encryptor.new(master_key).encrypt(value)
    end

    def decrypt(encrypted_data)
      ActiveVault::Encryptor.new(master_key).decrypt(encrypted_data)
    end
  end
end
