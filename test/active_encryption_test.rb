require 'test_helper'

class ActiveEncryption::Test < ActiveSupport::TestCase
  test "encryption and decryption works" do
    email = "dino@example.org"
    person = Person.create!(email: email)
    Person.last.email
    #assert_equal email, person.email
  end
end
