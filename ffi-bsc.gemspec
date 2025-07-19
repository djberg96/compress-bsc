require_relative 'lib/ffi_bsc/version'

Gem::Specification.new do |spec|
  spec.name          = "ffi-bsc"
  spec.version       = FFI_BSC::VERSION
  spec.authors       = ["Ruby Developer"]
  spec.email         = ["dev@example.com"]

  spec.summary       = "Ruby FFI bindings for libbsc (Block Sorting Compression Library)"
  spec.description   = "A Ruby interface to the libbsc high-performance block-sorting compression library using FFI"
  spec.homepage      = "https://github.com/example/ffi-bsc"
  spec.license       = "Apache-2.0"

  spec.files         = Dir["lib/**/*", "bin/**/*", "examples/**/*", "spec/**/*", "README.md", "LICENSE", "Gemfile", "Rakefile", "ffi-bsc.gemspec", "CHANGELOG.md"]
  spec.bindir        = "bin"
  spec.executables   = ["bsc_cli"]
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.7.0"

  spec.add_dependency "ffi", "~> 1.15"

  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "bundler", "~> 2.0"

  spec.metadata = {
    "homepage_uri" => spec.homepage,
    "source_code_uri" => spec.homepage,
    "changelog_uri" => "#{spec.homepage}/blob/main/CHANGELOG.md"
  }
end
