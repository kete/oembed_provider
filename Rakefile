require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "oembed_provider"
    gem.summary = %Q{A Rails engine to answer oEmbed requests for application media asset models.}
    gem.description = %Q{A Rails engine to answer oEmbed requests for application media asset models. In other words, this gem allows your application, after configuring the gem and the relevant models, to act as an oEmbed Provider by providing a controller that returns JSON or XML for a given oEmbed consumer request for the specified media asset. This gem does not offer oEmbed consumer functionality. (Rails 2.3.5 only for now)}
    gem.email = "walter@katipo.co.nz"
    gem.homepage = "http://github.com/kete/oembed_provider"
    gem.authors = ["Walter McGinnis"]
    gem.add_dependency "addressable"
    gem.add_development_dependency "thoughtbot-shoulda", ">= 0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  puts "This gem includes a full rails app for running tests (and staging development not yet extracted to the gem proper). Run tests there by changing to test/full_[RAIlS_VERSION_#_with_underscores]_app_with_tests and doing 'rake test'."
end

# require 'rake/testtask'
# Rake::TestTask.new(:test) do |test|
#   test.libs << 'lib' << 'test'
#   test.pattern = 'test/**/test_*.rb'
#   test.verbose = true
# end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "oembed_provider #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
