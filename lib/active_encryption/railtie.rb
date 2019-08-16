module ActiveEncryption
  class Railtie < ::Rails::Railtie
    config.active_encryption = ActiveSupport::OrderedOptions.new
    config.eager_load_namespaces << ActiveEncryption

    initializer "active_encryption.services" do
      config.after_initialize do |app|
        if config_choice = app.config.active_encryption.service
          config_file = Pathname.new(Rails.root.join("config/encryption.yml"))
          raise("Couldn't find Active Encryption configuration in #{config_file}") unless config_file.exist?

          require "yaml"
          require "erb"

          configs =
            begin
              YAML.load(ERB.new(config_file.read).result) || {}
            rescue Psych::SyntaxError => e
              raise "YAML syntax error occurred while parsing #{config_file}. " \
                "Please note that YAML must be consistently indented using spaces. Tabs are not allowed. " \
                "Error: #{e.message}"
            end

          ActiveEncryption.service =
            begin
              ActiveEncryption::Service.configure config_choice, configs
            rescue => e
              raise e, "Cannot load `Rails.config.active_encryption.service`:\n#{e.message}", e.backtrace
            end
        end
      end
    end

    initializer "active_encryption.model" do
      require "active_encryption/model"

      ActiveSupport.on_load(:active_record) do
        include ActiveEncryption::Model
      end
    end
  end
end
