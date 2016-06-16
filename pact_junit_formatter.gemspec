# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pact_junit_formatter/version'

Gem::Specification.new do |spec|
  spec.name          = "pact_junit_formatter"
  spec.version       = PactJunitFormatter::VERSION
  spec.authors       = ["Taiki Ono"]
  spec.email         = ["taiks.4559@gmail.com"]

  spec.summary       = %q{Dump pact verification result with JUnit format.}
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/taiki45/pact_junit_formatter"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'builder'
  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
end
