require File.expand_path("../lib/doppler-env/version", __FILE__)

Gem::Specification.new "doppler-env", DopplerEnv::VERSION do |gem|
  gem.authors       = ["Joel Watson"]
  gem.email         = ["joel.watson@doppler.com"]
  gem.description   = gem.summary = "Autoload secrets from Doppler."
  gem.homepage      = "https://github.com/dopplerhq/ruby-doppler-env"
  gem.license       = "Apache-2.0"
  gem.files         = [
    "README.md",
    "CHANGELOG.md",
    "LICENSE",
    "lib/doppler-env.rb",
    "lib/doppler-env/load.rb",
    "lib/doppler-env/version.rb"
  ]
end