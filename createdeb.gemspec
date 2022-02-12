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

	git_files         = Dir.chdir(File.expand_path('..', __FILE__)) do
		`git ls-files -z`.split("\x0")
	end
	spec.files         = git_files.grep_v(%r{^(test|spec|features)/})
	spec.bindir        = "exe"
	spec.executables   = git_files.grep(%r{^exe/}) { |f| File.basename(f) }
	spec.test_files    = git_files.grep(%r{^(test|spec|features)/})
	spec.require_paths = ["lib"]

	spec.required_ruby_version = Gem::Requirement.new(">= 2.7.4")
	spec.add_development_dependency "rake"
	spec.add_development_dependency "rspec"
end
