# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'holistics/version'

Gem::Specification.new do |spec|
  spec.name          = 'holistics-cli'
  spec.version       = Holistics::VERSION
  spec.authors       = ['Thanh Pham Minh']
  spec.email         = ['phamminhthanh69@gmail.com']

  spec.summary       = 'Holistics CommandLine Interface'
  spec.description   = 'CommandLine Interface for Holistics.io, proxy request through Holistics HTTP API'
  spec.homepage      = 'https://github.com/pmint93/holistics-cli'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = ['holistics']
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'byebug', '~> 9.0'

  spec.add_runtime_dependency 'thor', '~> 0.19.4'
  spec.add_runtime_dependency 'colorize', '0.8.1'
  spec.add_runtime_dependency 'table_print', '1.5.6'
  spec.add_runtime_dependency 'activesupport', '~> 4.2'
  spec.add_runtime_dependency 'faraday', '~> 0.11.0'
end
