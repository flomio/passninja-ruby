require_relative "lib/passninja/version"

Gem::Specification.new do |spec|
  spec.name          = "passninja-ruby"
  spec.version       = Passninja::VERSION
  spec.authors       = ["Richard Grundy"]
  spec.email         = ["info@passninja.com"]

  spec.summary       = %q{A Ruby gem for interacting with the PassNinja API}
  spec.description   = %q{This gem provides a Ruby interface for the PassNinja API, allowing you to create, get, update, and delete passes.}
  spec.homepage      = "https://github.com/flomio/passninja-ruby"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*.rb"]
  spec.require_paths = ["lib"]

  spec.add_dependency "net-http"
  spec.add_dependency "json"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "webmock"
end
