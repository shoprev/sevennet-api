# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "sevennet-api"
  spec.version       = Sevennet::Api::VERSION
  spec.authors       = ["shoprev"]
  spec.email         = ["admin@shoprev.net"]
  spec.description   = %q{Generic Ruby 7netshopping API}
  spec.summary       = %q{Generic Ruby 7netshopping API}
  spec.homepage      = "https://github.com/shoprev/sevennet-api"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  #spec.add_development_dependency "bundler", "~> 1.3"
  #spec.add_development_dependency "rake"
  spec.add_dependency "nokogiri", "~>1.6.0"
end
