# 
# Rake tasklib for testing tasks

# 
# Authors:
# * Michael Granger <ged@FaerieMUD.org>
# 

unless defined?( COVERAGE_MINIMUM )
	if ENV['COVVERAGE_MINIMUM']
		COVERAGE_MINIMUM = Float( ENV['COVERAGE_MINIMUM'] )
	else
		COVERAGE_MINIMUM = 85.0 
	end
end
SPEC_FILES       = [] unless defined?( SPEC_FILES )
TEST_FILES       = [] unless defined?( TEST_FILES )

COMMON_SPEC_OPTS = ['-Du'] unless defined?( COMMON_SPEC_OPTS )

COVERAGE_TARGETDIR = BASEDIR + 'coverage' unless defined?( COVERAGE_TARGETDIR )
RCOV_EXCLUDES      = 'spec,tests,/Library/Ruby,/var/lib,/usr/local/lib' unless
	defined?( RCOV_EXCLUDES )


desc "Run all defined tests"
task :test do
	unless SPEC_FILES.empty?
		log "Running specs"
		Rake::Task['spec:quiet'].invoke
	end

	unless TEST_FILES.empty?
		log "Running unit tests"
		Rake::Task[:unittests].invoke 
	end
end


### RSpec specifications
begin
	gem 'rspec', '>= 1.1.3'

	require 'spec'
	require 'spec/rake/spectask'

	### Task: spec
	desc "Run specs"
	task :spec => 'spec:doc'

	namespace :spec do
		desc "Run rspec every time there's a change to one of the files"
		task :autotest do
			require 'autotest/rspec'

			autotester = Autotest::Rspec.new
			autotester.run
		end

		desc "Generate regular color 'doc' spec output"
		Spec::Rake::SpecTask.new( :doc ) do |task|
			task.spec_files = SPEC_FILES
			task.spec_opts = COMMON_SPEC_OPTS + ['-f', 's', '-c']
		end

		desc "Generate spec output with profiling"
		Spec::Rake::SpecTask.new( :profile ) do |task|
			task.spec_files = SPEC_FILES
			task.spec_opts = COMMON_SPEC_OPTS + ['-f', 'o']
		end

		desc "Generate quiet non-colored plain-text output"
		Spec::Rake::SpecTask.new( :quiet ) do |task|
			task.spec_files = SPEC_FILES
			task.spec_opts = COMMON_SPEC_OPTS + ['-f', 'p']
		end

		desc "Generate HTML output"
		Spec::Rake::SpecTask.new( :html ) do |task|
			task.spec_files = SPEC_FILES
			task.spec_opts = COMMON_SPEC_OPTS + ['-f', 'h']
		end

	end
rescue LoadError => err
	task :no_rspec do
		$stderr.puts "Specification tasks not defined: %s" % [ err.message ]
	end

	task :spec => :no_rspec
	namespace :spec do
		task :autotest => :no_rspec
		task :doc => :no_rspec
		task :profile => :no_rspec
		task :quiet => :no_rspec
		task :html => :no_rspec
	end
end


### Test::Unit tests
begin
	require 'rake/testtask'

	Rake::TestTask.new( :unittests ) do |task|
		task.libs += [LIBDIR]
		task.test_files = TEST_FILES
		task.verbose = true
	end

rescue LoadError => err
	task :no_test do
		$stderr.puts "Test tasks not defined: %s" % [ err.message ]
	end

	task :unittests => :no_rspec
end


### RCov (via RSpec) tasks
begin
	gem 'rcov'
	gem 'rspec', '>= 1.1.3'

	require 'spec'
	require 'rcov'

	### Task: coverage (via RCov)
	desc "Build test coverage reports"
	unless SPEC_FILES.empty?
		Spec::Rake::SpecTask.new( :coverage ) do |task|
			task.spec_files = SPEC_FILES
			task.libs += [LIBDIR]
			task.spec_opts = ['-f', 'p', '-b']
			task.rcov_opts = RCOV_OPTS
			task.rcov = true
		end
	end


	### Task: rcov
	task :rcov => :coverage

	### Other coverage tasks
	namespace :coverage do
		desc "Generate a detailed text coverage report"
		Spec::Rake::SpecTask.new( :text ) do |task|
			task.spec_files = SPEC_FILES
			task.rcov_opts = RCOV_OPTS + ['--text-report']
			task.rcov = true
		end

		desc "Show differences in coverage from last run"
		Spec::Rake::SpecTask.new( :diff ) do |task|
			task.spec_files = SPEC_FILES
			task.spec_opts = ['-f', 'p', '-b']
			task.rcov_opts = RCOV_OPTS - ['--save'] + ['--text-coverage-diff']
			task.rcov = true
		end

		desc "Run RCov in 'spec-only' mode to check coverage from specs"
		Spec::Rake::SpecTask.new( :speconly ) do |task|
			task.spec_files = SPEC_FILES
			task.rcov_opts = ['--exclude', RCOV_EXCLUDES, '--text-report', '--save']
			task.rcov = true
		end
	end

	CLOBBER.include( COVERAGE_TARGETDIR )

rescue LoadError => err
	task :no_rcov do
		$stderr.puts "Coverage tasks not defined: RSpec+RCov tasklib not available: %s" %
		[ err.message ]
	end

	task :coverage => :no_rcov
	task :clobber_coverage
	task :rcov => :no_rcov
	namespace :coverage do
		task :text => :no_rcov
		task :diff => :no_rcov
	end
	task :verify => :no_rcov
end


