# frozen_string_literal: true

require 'test_helper'

if SERVICE_CONFIGURATIONS[:hashicorp]
  class ActiveVault::Service::VaultServiceTest < ActiveSupport::TestCase
    SERVICE = ActiveVault::Service.configure(:hashicorp, SERVICE_CONFIGURATIONS)

    test "encrypts and decrypts provided with Hashicorp Vault" do
      random_text = SecureRandom.random_bytes(32)

      ciphertext = SERVICE.encrypt(random_text)
      assert ciphertext

      plaintext = SERVICE.decrypt(ciphertext)
      assert_equal plaintext, random_text
    end
  end
else
  puts "Skipping Hashicorp Vault tests because no Vault configuration was supplied"
end
