# frozen_string_literal: true

module ActiveVault
  # Provides class-level DSL for declaring an Active Record model's encryption.
  # Encryption/decryption is performed using a Envelope symetric key encryption.
  module Model
    extend ActiveSupport::Concern

    class_methods do
      # Defines encrypted attributes
      #
      #   class Person < AppilcationRecord
      #     encrypts :email
      #   end
      #
      # This exposes +email+ virtual attribute that must be backed with 2 database
      # columns:
      #   * `email_ciphertext` - stored encrypted vaule
      #   * `encrypted_vault_key` - key that knows how to decrypt attributes
      #      This key is encrypted with configured +ActiveVault::Service+, and
      #      server as a backbone to envelope encryption.
      def encrypts(*attributes, encode: true, **options)
        attributes.each do |name|
          encrypted_attribute = "#{name}_ciphertext"
          name = name.to_sym
          class_method_name = "generate_#{encrypted_attribute}"

          class_eval do
            attribute name, :string

            # Defines setter for virtual attribute. This method performs
            # encryption of plaintext and stored `encrypted_vault_key`
            #
            #   Person.create(email: "dino@exmaple.org") => encrypts eamil.
            define_method "#{name}=" do |message|
              ciphertext = if message.blank?
                message
              else
                key = generate_random_key
                encrypted_key = ActiveVault.service.encrypt(key)

                self.encrypted_vault_key = encrypted_key
                self.class.send(class_method_name, key, message)
              end

              send("#{encrypted_attribute}=", ciphertext)

              super(message)
            end

            # Defines getter method. This method decrypts stored value.
            #
            #   person.email  => "dino@example.org"
            define_method "#{name}" do
              message = super()

              unless message
                ciphertext = send(encrypted_attribute)
                key = ActiveVault.service.decrypt(self.encrypted_vault_key)
                message= Cipher.new(key).decrypt(ciphertext)
              end

              # Set previous attribute on first decrypt
              @attributes[name.to_s].instance_variable_set("@value_before_type_cast", message)

              if respond_to?(:_write_attribute, true)
                _write_attribute(name, message)
              else
                raw_write_attribute(name, message)
              end

              message
            end

            define_singleton_method class_method_name do |key, message, **opts|
              Cipher.new(key).encrypt(message)
            end

            # Generates random 32-bytes long key that will encrypt/decrypt
            # attributes. Each db record gets it's own key.
            # This key is then encrypted with KMS and stored inside `encrypted_vault_key`
            # column.
            #
            # Key must be 32-bytes long since aes-256-gcm requires key that
            # length.
            def generate_random_key
              SecureRandom.random_bytes(32)
            end
          end
        end
      end
    end
  end
end
