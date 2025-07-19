require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

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
    require_relative 'lib/ffi_bsc'
    FFI_BSC::Library # Try to load the library
    puts "✓ libbsc library found and loaded successfully"
  rescue LoadError => e
    puts "✗ libbsc library not found: #{e.message}"
    puts "\nTo install libbsc:"
    puts "  macOS: rake install_libbsc_mac"
    puts "  Ubuntu/Debian: rake install_libbsc_ubuntu"
    puts "  From source: rake build_libbsc"
  end
end
