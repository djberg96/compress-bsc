require_relative 'lib/compress/bsc/version'

Gem::Specification.new do |spec|
  spec.name        = 'compress-bsc'
  spec.version     = Compress::BSC::VERSION
  spec.author      = 'Daniel Beger'
  spec.email       = 'djberg96@gmail.com'

  spec.summary     = 'Ruby FFI bindings for libbsc (Block Sorting Compression Library)'
  spec.homepage    = 'https://github.com/djberg96/compress-bsc'
  spec.license     = 'Apache-2.0'

  spec.files       = Dir['**/*'].reject{ |f| f.include?('git') }
  spec.bindir      = 'bin'
  spec.executables = ['rbsc']
  spec.cert_chain  = ['certs/djberg96_pub.pem']

  spec.required_ruby_version = '>= 2.7.0'

  spec.add_dependency 'ffi', '~> 1.15'

  spec.add_development_dependency 'rspec', '~> 3.12'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'simplecov', '~> 0.22'
  spec.add_development_dependency 'rubocop', '~> 1.50'
  spec.add_development_dependency 'yard', '~> 0.9'

  spec.metadata = {
    'homepage_uri'          => 'https://github.com/djberg96/compress-bsc',
    'bug_tracker_uri'       => 'https://github.com/djberg96/compress-bsc/issues',
    'changelog_uri'         => 'https://github.com/djberg96/compress-bsc/blob/main/CHANGES.md',
    'documentation_uri'     => 'https://github.com/djberg96/compress-bsc/wiki',
    'source_code_uri'       => 'https://github.com/djberg96/compress-bsc',
    'wiki_uri'              => 'https://github.com/djberg96/compress-bsc/wiki',
    'rubygems_mfa_required' => 'true',
    'github_repo'           => 'https://github.com/djberg96/compress-bsc',
    'funding_uri'           => 'https://github.com/sponsors/djberg96'
  }

  spec.description = <<-EOF
    A Ruby interface to the libbsc high-performance block-sorting compression library
    from Ilya Grebnov using FFI.
  EOF
end
