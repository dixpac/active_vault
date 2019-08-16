module ActiveEncryption
  class Service::LocalService < Service
    attr_reader :master_key

    def initialize(master_key:)
      @master_key = master_key
    end

    def encrypt(message, table_name, attribute)
      key = KeyGenerator.new(master_key).attribute_key(table: table_name, attribute: attribute)

      ciphertext = Encryptor.new(key).encrypt(message)
      Base64.strict_encode64(ciphertext)
    end

    def decrypt(ciphertext, table_name, attribute)
      return ciphertext if ciphertext.nil?

      key = KeyGenerator.new(master_key).attribute_key(table: table_name, attribute: attribute)

      Encryptor.new(key).decrypt(Base64.decode64(ciphertext))
    end
  end
end
