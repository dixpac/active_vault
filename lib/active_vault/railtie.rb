module ActiveVault
  class Railtie < ::Rails::Railtie
    config.active_vault = ActiveSupport::OrderedOptions.new
    config.eager_load_namespaces << ActiveVault

    initializer "active_vault.services" do
      config.after_initialize do |app|
        if config_choice = app.config.active_vault.service
          config_file = Pathname.new(Rails.root.join("config/vault.yml"))
          raise("Couldn't find Active Vault configuration in #{config_file}") unless config_file.exist?

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

          ActiveVault.service =
            begin
              ActiveVault::Service.configure config_choice, configs
            rescue => e
              raise e, "Cannot load `Rails.config.active_vault.service`:\n#{e.message}", e.backtrace
            end
        end
      end
    end

    initializer "active_vault.model" do
      require "active_vault/model"

      ActiveSupport.on_load(:active_record) do
        include ActiveVault::Model
      end
    end
  end
end
