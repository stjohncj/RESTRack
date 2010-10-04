require 'rake'
require 'rake/testtask'

task :default => [:test]

desc 'Run all tests.'
Rake::TestTask.new('test') { |t|
  t.pattern = 'test/**/test_*.rb'
  t.verbose = true
  t.warning = true
}