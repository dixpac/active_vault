require 'test_helper'

class ActiveVault::PeronTest < ActiveSupport::TestCase
  test "encryption and decryption works" do
    email = "dino@example.org"
    person = Person.create!(email: email)

    assert_equal email, person.email
    assert person.email_ciphertext
    assert person.encrypted_vault_key
    person.reload
    assert_equal email, person.email
  end
end
