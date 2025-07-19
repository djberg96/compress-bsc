require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'yard'

CLEAN.include("**/*.gem", "**/*.rbx", "**/*.rbc", "ruby.core", "**/*.lock")

namespace :gem do
  desc "Create the compress-bsc gem"
  task :create => [:clean] do
    require 'rubygems/package'
    spec = Gem::Specification.load('compress-bsc.gemspec')
    spec.signing_key = File.join(Dir.home, '.ssh', 'gem-private_key.pem')
    Gem::Package.build(spec)
  end

  desc "Install the compress-bsc gem"
  task :install => [:create] do
    file = Dir["*.gem"].first
    sh "gem install -l #{file}"
  end
end

# Default RSpec task
RSpec::Core::RakeTask.new(:spec) do |task|
  task.rspec_opts = ['--color', '--format', 'documentation']
end

# RSpec task with coverage
RSpec::Core::RakeTask.new(:spec_with_coverage) do |task|
  task.rspec_opts = ['--color', '--format', 'documentation']
  ENV['COVERAGE'] = 'true'
end

# RSpec task with verbose output
RSpec::Core::RakeTask.new(:spec_verbose) do |task|
  task.rspec_opts = ['--color', '--format', 'documentation', '--backtrace']
end

# RSpec task for CI environments
RSpec::Core::RakeTask.new(:spec_ci) do |task|
  task.rspec_opts = ['--color', '--format', 'progress', '--format', 'RspecJunitFormatter', '--out', 'tmp/rspec.xml']
end

task default: :spec

# Documentation tasks
YARD::Rake::YardocTask.new do |task|
  task.files   = ['lib/**/*.rb']
  task.options = ['--markup', 'markdown', '--readme', 'README.md']
end

desc "Generate documentation and open it"
task :doc => :yard do
  system "open doc/index.html" if RUBY_PLATFORM =~ /darwin/
end

# Code quality tasks
begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
rescue LoadError
  # RuboCop not available
end

desc "Install libbsc on macOS using Homebrew"
task :install_libbsc_mac do
  puts "Installing libbsc on macOS..."
  sh "brew install libbsc" rescue puts "Failed to install via Homebrew. Please install libbsc manually."
end

desc "Install libbsc on Ubuntu/Debian"
task :install_libbsc_ubuntu do
  puts "Installing libbsc on Ubuntu/Debian..."
  sh "sudo apt-get update && sudo apt-get install -y libbsc-dev" rescue puts "Failed to install via apt. Please install libbsc manually."
end

desc "Build libbsc from source"
task :build_libbsc do
  puts "Building libbsc from source..."
  puts "Please follow the instructions at: https://github.com/IlyaGrebnov/libbsc"
end

desc "Check if libbsc is available"
task :check_libbsc do
  begin
    require_relative 'lib/compress/bsc'
    Compress::BSC::Library # Try to load the library
    puts "✓ libbsc library found and loaded successfully"
  rescue LoadError => e
    puts "✗ libbsc library not found: #{e.message}"
    puts "\nTo install libbsc:"
    puts "  macOS: rake install_libbsc_mac"
    puts "  Ubuntu/Debian: rake install_libbsc_ubuntu"
    puts "  From source: rake build_libbsc"
  end
end
