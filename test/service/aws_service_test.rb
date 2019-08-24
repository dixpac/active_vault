# frozen_string_literal: true

require 'test_helper'

if SERVICE_CONFIGURATIONS[:aws]
  class ActiveVault::Service::AwsServiceTest < ActiveSupport::TestCase
    SERVICE = ActiveVault::Service.configure(:aws, SERVICE_CONFIGURATIONS)

    test "encrypts and decrypts provided with AWS KMS" do
      random_text = SecureRandom.random_bytes(32)

      ciphertext = SERVICE.encrypt(random_text)
      assert ciphertext

      plaintext = SERVICE.decrypt(ciphertext)
      assert_equal plaintext, random_text
    end
  end
else
  puts "Skipping AWS KMS Service tests because no AWS configuration was supplied"
end
