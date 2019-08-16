class ActiveEncryption::Service::Configurator #:nodoc:
  attr_reader :configurations

  def self.build(service_name, configurations)
    new(configurations).build(service_name)
  end

  def initialize(configurations)
    @configurations = configurations.deep_symbolize_keys
  end

  def build(service_name)
    config = config_for(service_name.to_sym)
    resolve(config.fetch(:service)).build(**config, configurator: self)
  end

  private
    def config_for(name)
      configurations.fetch name do
        raise "Missing configuration for the #{name.inspect} Active Encryption service. Configurations available for #{configurations.keys.inspect}"
      end
    end

    def resolve(class_name)
      require "active_encryption/service/#{class_name.to_s.downcase}_service"
      ActiveEncryption::Service.const_get(:"#{class_name}Service")
    end
end
