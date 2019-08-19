module ActiveVault
  class Service
    extend ActiveSupport::Autoload
    autoload :Configurator

    class << self
      def configure(service_name, configurations)
        Configurator.build(service_name, configurations)
      end

      def build(configurator:, service: nil, **service_config)
        new(**service_config)
      end
    end
  end
end
