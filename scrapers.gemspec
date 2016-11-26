# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'scrapers/version'

Gem::Specification.new do |spec|
  spec.name          = "scrapers"
  spec.version       = Scrapers::VERSION
  spec.authors       = ["Zequez"]
  spec.email         = ["zequez@gmail.com"]
  spec.summary       = %q{Scrapers for GGFilter}
  spec.description   = %q{This is a scraping library and bundle of scrapers for the GGFinder app}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "typhoeus", "~> 0.7"
  spec.add_dependency "nokogiri", "~> 1.6"
  spec.add_dependency "activerecord", ">= 4.2"
  spec.add_dependency "colorize", "~> 0.7"
  spec.add_dependency "simple_flaggable_column", ">= 0.0.2"
  spec.add_dependency "awesome_print", "~> 1.6"
  spec.add_dependency "i18n_data", "~> 0.7"
  spec.add_dependency "sendgrid-ruby", "~> 4.0"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.3"
  spec.add_development_dependency "rspec-its", "~> 1.2"
  spec.add_development_dependency "rspec-mocks", "~> 3.3"
  spec.add_development_dependency "guard", "~> 2.13"
  spec.add_development_dependency "guard-rspec", "~> 4.6"
  spec.add_development_dependency "webmock", "~> 1.21"
  spec.add_development_dependency "vcr", "~> 2.9"
  spec.add_development_dependency "with_model", "~> 1.2"
  spec.add_development_dependency "database_cleaner", "~> 1.4"
  spec.add_development_dependency "sqlite3", "~> 1.3"
  spec.add_development_dependency "byebug", "~> 6"
  spec.add_development_dependency "dotenv", "~> 2.1"
end
