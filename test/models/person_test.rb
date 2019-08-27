# frozen_string_literal: true

require 'test_helper'

class ActiveVault::PeronTest < ActiveSupport::TestCase
  setup do
    @email = "dino@example.org"
    @person = Person.create!(email: @email)
  end

  test "when saving new row encryption and decryption works" do
    assert_equal @email, @person.email
    assert @person.email_ciphertext
    assert @person.encrypted_vault_key
    @person.reload
    assert_equal @email, @person.email

    @person.rotate_vault_key!
  end

  test "when updating encrypted attribute encyption work base on already stored key" do
    new_email = "new@example.org"
    key = @person.encrypted_vault_key
    ciphertext = @person.email_ciphertext

    @person.update!(email: new_email)

    assert_equal new_email, @person.email
    assert_not_equal @person.email_ciphertext, ciphertext
    assert_equal @person.encrypted_vault_key, key
  end

  test "when executing rotate_vault_key! if changes encryption key and re-encrypts data with the new key" do
    old_key = @person.encrypted_vault_key
    old_ciphertext = @person.email_ciphertext
    old_plaintext = @person.email

    @person.rotate_vault_key!

    refute_equal @person.encrypted_vault_key, old_key
    refute_equal @person.email_ciphertext, old_ciphertext
    assert_equal @person.email, old_plaintext
  end
end
