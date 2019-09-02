# frozen_string_literal: true

require 'test_helper'

class ActiveVault::Service::LocalServiceTest < ActiveSupport::TestCase
  SERVICE = ActiveVault::Service::Configurator.build(:test, test: { service: "Local", master_key: "123" })

  test "encrypts and decrypts data with insecure local mock" do
    random_text = SecureRandom.random_bytes(32)

    ciphertext = SERVICE.encrypt(random_text)
    assert ciphertext

    plaintext = SERVICE.decrypt(ciphertext)
    assert_equal plaintext, random_text
  end
end
