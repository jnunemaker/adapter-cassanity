# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'adapter/cassanity/version'

Gem::Specification.new do |gem|
  gem.name          = "adapter-cassanity"
  gem.version       = Adapter::Cassanity::VERSION
  gem.authors       = ["John Nunemaker"]
  gem.email         = ["nunemaker@gmail.com"]
  gem.description   = %q{Adapter for Cassanity}
  gem.summary       = %q{Adapter for Cassanity}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'adapter', '~> 0.7.0'
  gem.add_dependency 'cassanity', '~> 0.2.1'
end
