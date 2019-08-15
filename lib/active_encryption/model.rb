# frozen_string_literal: true

module ActiveEncryption
  module Model
    extend ActiveSupport::Concern

    class_methods do
      def encrypts(*attributes, encode: true, **options)
        attributes.each do |name|
          encrypted_attribute = "#{name}_ciphertext"
          name = name.to_sym
          class_method_name = "generate_#{encrypted_attribute}"

          class_eval do
            attribute name, :string

            define_method "#{name}=" do |message|
              ciphertext = if message.blank?
                message
              else
                self.class.send(class_method_name, message, context: self)
              end

              send("#{encrypted_attribute}=", ciphertext)

              super(message)
            end

            define_method "#{name}" do
              message = super()

              # Set previous attribute on first decrypt
              @attributes[name.to_s].instance_variable_set("@value_before_type_cast", message)

              if respond_to?(:_write_attribute, true)
                _write_attribute(name, message)
              else
                raw_write_attribute(name, message)
              end

              message
            end

            define_singleton_method class_method_name do |message, **opts|
              key = KeyGenerator.new("master").attribute_key(table: table_name, attribute: encrypted_attribute)
              ciphertext = Encryptor.new(key).encrypt(message)
              Base64.strict_encode64(ciphertext)
            end
          end
        end
      end
    end
  end
end
