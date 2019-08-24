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
end
