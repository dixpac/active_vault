module ActiveEncryption
  class Service::LocalService < Service
    attr_reader :master_key

    def initialize(master_key:)
      @master_key = master_key
    end

    def encrypt(message, table_name, attribute)
      key = KeyGenerator.new(master_key).attribute_key(table: table_name, attribute: attribute)
      Encryptor.new(key).encrypt(message)
    end

    def decrypt(ciphertext, table_name, attribute)
      return ciphertext if ciphertext.nil?

      key = KeyGenerator.new(master_key).attribute_key(table: table_name, attribute: attribute)
      key = decode_key(key)
      Encryptor.new(key).decrypt(ciphertext)
    end

    private
      def decode_key(key)
        if key.encoding != Encoding::BINARY && key =~ /\A[0-9a-f]{64,128}\z/i
          key = [key].pack("H*")
        end

        key
      end
  end
end
