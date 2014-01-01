task :default => :spec

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = 'my_specs.rb'
end

namespace :spec do
  %W(dns gittfs blog church market).each do |tag|
    desc "Run just the #{tag} specs"
    RSpec::Core::RakeTask.new(tag) do |spec|
      spec.pattern = 'my_specs.rb'
      spec.rspec_opts = "-t #{tag}"
    end
  end
end
