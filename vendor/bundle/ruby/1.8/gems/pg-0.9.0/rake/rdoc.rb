# 
# RDoc Rake tasks

# 

gem 'rdoc', '>= 2.4.3'

require 'rubygems'
require 'rdoc/rdoc'
require 'rake/clean'
require 'rdoc/task'

# Append docs/lib to the load path if it exists for a locally-installed Darkfish
DOCSLIB = DOCSDIR + 'lib'
$LOAD_PATH.unshift( DOCSLIB.to_s ) if DOCSLIB.exist?

# Make relative string paths of all the stuff we need to generate docs for
DOCFILES = Rake::FileList[ LIB_FILES + EXT_FILES + GEMSPEC.extra_rdoc_files ]


directory RDOCDIR.to_s
CLOBBER.include( RDOCDIR )

desc "Build API documentation in #{RDOCDIR}"
RDoc::Task.new do |task|
	task.main = "README"
	task.rdoc_files.include( DOCFILES )
	task.rdoc_dir = RDOCDIR.to_s
	task.options = RDOC_OPTIONS
end
