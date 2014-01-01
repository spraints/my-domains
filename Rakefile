task :default => :spec

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = 'my_specs.rb'
end

namespace :spec do
  desc "Run just the dns specs"
  RSpec::Core::RakeTask.new(:dns) do |spec|
    spec.pattern = 'my_specs.rb'
    spec.rspec_opts = '-t dns'
  end
end
