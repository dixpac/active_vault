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
      #   * `email_encrypted` - stored encrypted vaule
      #   * `encrypted_key` - key that knows how to decrypt attributes
      #      This key is encrypted with configured +ActiveVault::Service+, and
      #      serves as a backbone to envelope encryption.
      def encrypts(*attributes, encode: true, **options)
        attributes.each do |name|
          encrypted_attribute = "#{name}_encrypted"
          name = name.to_sym

          class_eval do
            attribute name, :string

            # Defines setter for virtual attribute. This method performs
            # encryption of value and handles `encrypted_key`
            #
            #   Person.create(email: "dino@exmaple.org") => encrypts email
            define_method "#{name}=" do |value|
              plaintext_key = EncryptionKey.for self
              self.encrypted_key = ActiveVault.service.encrypt(plaintext_key) if self.encrypted_key.blank?

              encrypted_data = encrypt key: plaintext_key, value: value
              send("#{encrypted_attribute}=", encrypted_data)

              super(value)
            end

            # Defines getter method. This method decrypts stored value.
            #
            #   person.email  => "dino@example.org"
            define_method "#{name}" do
              value = super()
              value = decrypt attribute: encrypted_attribute unless value

              # Set previous attribute on first decrypt
              @attributes[name.to_s].instance_variable_set("@value_before_type_cast", value)

              if respond_to?(:_write_attribute, true)
                _write_attribute(name, value)
              else
                raw_write_attribute(name, value)
              end

              value
            end
          end
        end
      end
    end

    # Rotates encryption key on the record. Generate the new key and encrypts
    # record wit the new key
    #
    #   @person.rotate_key!
    def rotate_key!
      vault_attributes = self.class.attribute_names.find_all { |el| el.include?("_encrypted") }
      return if vault_attributes.blank?

      clear_encryption_key
      re_encrypt vault_attributes

      save!
    end

    private
      def encrypt(key:, value:)
        return unless value
        Encryptor.new(key).encrypt(value)
      end

      def decrypt(attribute:)
        key = ActiveVault.service.decrypt(encrypted_key)
        encrypted_data = send(attribute)

        Encryptor.new(key).decrypt(encrypted_data)
      end

      def clear_encryption_key
        self.encrypted_key = nil
      end

      def re_encrypt(attributes)
        attributes.each do |attr|
          value = send("#{attr.chomp("_encrypted")}")
          send("#{attr}=", value)
        end
      end
  end
end
