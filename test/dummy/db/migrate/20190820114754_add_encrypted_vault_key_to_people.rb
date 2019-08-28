class AddEncryptedVaultKeyToPeople < ActiveRecord::Migration[6.0]
  def change
    add_column :people, :encrypted_key, :text
  end
end
