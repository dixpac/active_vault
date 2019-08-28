# frozen_string_literal: true

require 'test_helper'

class ActiveVault::EncryptionKeyTest < ActiveSupport::TestCase
  test "returns new random key when saving new record" do
    person = Person.new(email: "dino@example.org")
    plaintext_key = ActiveVault::EncryptionKey.for person
    assert_equal 32, plaintext_key.bytesize
  end

  test "returns decrypted key on record updating" do
    person = Person.new(email: "dino@example.org")
    person.save

    plaintext_key = ActiveVault::EncryptionKey.for person

    assert_equal ActiveVault.service.decrypt(person.encrypted_key), plaintext_key
  end
end
