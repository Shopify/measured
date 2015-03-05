require "bundler/gem_tasks"
require 'rake/testtask'

$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "measured/version"

task default: :test

desc 'Run the test stuite'
Rake::TestTask.new do |t|
  t.libs << "test"
  t.libs << "lib/**/*"
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end

task tag: :build do
  system "git commit -m'Released version #{ Measured::VERSION }' --allow-empty"
  system "git tag -a v#{ Measured::VERSION } -m 'Tagging #{ Measured::VERSION }'"
  system "git push --tags"
end
