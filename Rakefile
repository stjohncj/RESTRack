require 'rake'
require 'rake/testtask'

task :default => [:test_all]

desc 'Run all tests.'
Rake::TestTask.new('test_all') { |t|
  t.pattern = 'test/**/test_*.rb'
}

desc 'Run sample_app_1 tests.'
Rake::TestTask.new('test1') { |t|
  t.pattern = 'test/sample_app_1/**/test_*.rb'
}

desc 'Run sample_app_2 tests.'
Rake::TestTask.new('test2') { |t|
  t.pattern = 'test/sample_app_2/**/test_*.rb'
}

desc 'Run sample_app_3 tests.'
Rake::TestTask.new('test3') { |t|
  t.pattern = 'test/sample_app_3/**/test_*.rb'
}

desc 'Run sample_app_4 tests.'
Rake::TestTask.new('test4') { |t|
  t.pattern = 'test/sample_app_4/**/test_*.rb'
}
