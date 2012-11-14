require 'rake'
require 'rake/testtask'

require 'bundler'
Bundler::GemHelper.install_tasks

task :default => [:test_all]

desc 'Run all tests.'
task :test_all do
  for n in 0..5
    Rake::Task['test'+n.to_s].invoke
  end
end

desc 'Run base tests.'
Rake::TestTask.new('test0') { |t|
  t.pattern = 'test/test_*.rb'
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


desc 'Run sample_app_5 tests.'
Rake::TestTask.new('test5') { |t|
  t.pattern = 'test/sample_app_5/**/test_*.rb'
}
