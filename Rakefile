# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = "exacttarget"
  gem.homepage = "http://github.com/msimpson/exacttarget"
  gem.license = "MIT"
  gem.summary = %Q{An XML API client for the ExactTarget email system.}
  gem.description =
  %Q{ExactTarget is a client system for communicating with the ExactTarget email system. The client supports the most up-to-date XML API and is capable of uploading email pastes, images and retrieving lists of subscribers, emails and more.}
  gem.email = "matt.simpson@alextom.com"
  gem.authors = ["Matthew Simpson"]
end
Jeweler::RubygemsDotOrgTasks.new

require 'rcov/rcovtask'
Rcov::RcovTask.new do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
  test.rcov_opts << '--exclude "gems/*"'
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "exacttarget #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
