# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
	spec.name          = "createdeb"
	spec.version       = "0.0.1.dev"
	spec.authors       = ["Gioele Barabucci"]
	spec.email         = ["gioele@svario.it"]
	spec.summary       = "A simple way to create Debian packages"
	spec.description   = "createdeb generates Debian packages from simple package descriptors."
	spec.homepage      = "http://svario.it/createdeb"
	spec.license       = "CC0"

	spec.files         = `git ls-files`.split($/)
	spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
	spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
	spec.require_paths = ["lib"]

	spec.add_development_dependency "bundler", "~> 1.12"
	spec.add_development_dependency "rake"
	spec.add_development_dependency "rspec"
end
