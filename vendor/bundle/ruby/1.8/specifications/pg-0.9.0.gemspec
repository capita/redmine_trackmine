# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{pg}
  s.version = "0.9.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Michael Granger"]
  s.date = %q{2010-02-28}
  s.description = %q{This is the extension library to access a PostgreSQL database from Ruby.
This library works with PostgreSQL 7.4 and later.}
  s.email = ["ged@FaerieMUD.org"]
  s.extensions = ["ext/extconf.rb"]
  s.extra_rdoc_files = ["ChangeLog", "README", "LICENSE"]
  s.files = ["Rakefile", "ChangeLog", "README", "LICENSE", "spec/m17n_spec.rb", "spec/pgconn_spec.rb", "spec/pgresult_spec.rb", "spec/lib/helpers.rb", "lib/pg.rb", "ext/compat.c", "ext/pg.c", "ext/compat.h", "ext/pg.h", "ext/extconf.rb", "rake/191_compat.rb", "rake/dependencies.rb", "rake/helpers.rb", "rake/hg.rb", "rake/manual.rb", "rake/packaging.rb", "rake/publishing.rb", "rake/rdoc.rb", "rake/style.rb", "rake/svn.rb", "rake/testing.rb", "rake/verifytask.rb", "./README.ja", "./README.OS_X", "./README.windows", "./GPL", "./BSD", "./Contributors", "Rakefile.local", "spec/data/expected_trace.out", "spec/data/random_binary_data"]
  s.homepage = %q{http://bitbucket.org/ged/ruby-pg/}
  s.rdoc_options = ["-w", "4", "-HN", "-i", ".", "-m", "README", "-t", "pg", "-W", "http://bitbucket.org/ged/ruby-pg/browser/"]
  s.require_paths = ["lib", "ext"]
  s.requirements = ["PostgreSQL >=7.4"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{A Ruby interface to the PostgreSQL RDBMS}
  s.test_files = ["spec/m17n_spec.rb", "spec/pgconn_spec.rb", "spec/pgresult_spec.rb", "spec/lib/helpers.rb", "spec/data/expected_trace.out", "spec/data/random_binary_data"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
