module ActiveEncryption
  class Railtie < ::Rails::Railtie
    initializer "active_encryption.model" do
      require "active_encryption/model"

      ActiveSupport.on_load(:active_record) do
        include ActiveEncryption::Model
      end
    end
  end
end
