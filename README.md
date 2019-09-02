**building...**
Easy way to encrypt database columns and file uploads in Rails.

# Example

```ruby
# config/vault.yml
amazon:
 service: Aws
 key_id: "..."
 access_key: "..."
 secret_access: "..."
```

```ruby
# model
class Person < ApplicationRecord
  encrypts :email
end
```

```ruby
# db schema
create_table "people", force: :cascade do |t|
  t.text "email_encrypted"
  t.text "encrypted_key"
   ...
end
```
