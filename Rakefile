require 'rake'
require 'rake/testtask'

task :default => [:test]

desc 'Run all tests.'
Rake::TestTask.new('test') { |t|
  t.pattern = 'test/sample_app/test/test_*.rb'
}