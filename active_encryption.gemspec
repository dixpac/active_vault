$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "active_encryption/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "active_encryption"
  spec.version     = ActiveEncryption::VERSION
  spec.authors     = ["Dino Maric"]
  spec.email       = ["dino.onex@gmail.com"]
  spec.homepage    = "https://rubyonrails.org/"
  spec.summary     = "Encryption framework for Rails."
  spec.description = "Encrypt and decrypt database fiels with Rails."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.required_ruby_version = ">= 2.5.0"

  spec.add_dependency "rails", "~> 6.0.0.rc2"

  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "rails", ">= 5"
  spec.add_development_dependency "minitest", ">= 5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "byebug"
end
