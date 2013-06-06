# encoding: utf-8
lib = File.expand_path( "../lib", __FILE__ )
$LOAD_PATH.unshift( lib ) unless $LOAD_PATH.include? lib
require "mind_control/version"

Gem::Specification.new do |spec|
  spec.name          = "mind_control"
  spec.version       = MindControl::VERSION
  spec.authors       = [ "Denis Diachkov" ]
  spec.email         = [ "d.diachkov@gmail.com" ]
  spec.summary       = "Embeddable runtime Pry-based REPL console"
  spec.homepage      = "https://github.com/ddiachkov/mind_control"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split( $/ )
  spec.executables   = spec.files.grep( %r{^bin/} ) { |f| File.basename f }
  spec.test_files    = spec.files.grep( %r{^(test|spec|features)/} )
  spec.require_paths = [ "lib" ]

  spec.add_dependency "highline", "~> 1.6"
  spec.add_dependency "pry", "~> 0.9"
  spec.add_dependency "coolline", "~> 0.4"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "mocha"
  spec.add_development_dependency "eventmachine"
end