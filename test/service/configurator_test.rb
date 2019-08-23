# frozen_string_literal: true

class ActiveVault::Service::ConfiguratorTest < ActiveSupport::TestCase
  test "builds correct service instance based on service name" do
    service = ActiveVault::Service::Configurator.build(:foo, foo: aws_config_hash)
    assert_instance_of ActiveVault::Service::AwsService, service
    assert_equal "aws/key", service.key_id
    assert_equal "123", service.access_key
    assert_equal "321", service.secret_access
  end

  test "builds correct service instance based on lowercase service name" do
    service = ActiveVault::Service::Configurator.build(:foo, foo: aws_config_hash)
    assert_instance_of ActiveVault::Service::AwsService, service
    assert_equal "aws/key", service.key_id
    assert_equal "123", service.access_key
    assert_equal "321", service.secret_access
  end

  test "raises error when passing non-existent service name" do
    assert_raise RuntimeError do
      ActiveVault::Service::Configurator.build(:bigfoot, {})
    end
  end

  def aws_config_hash
    {
      service: "Aws",
      key_id: "aws/key",
      access_key: "123",
      secret_access: "321"
    }
  end
end
