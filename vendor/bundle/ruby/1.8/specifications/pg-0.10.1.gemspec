# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{pg}
  s.version = "0.10.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jeff Davis", "Michael Granger"]
  s.cert_chain = ["-----BEGIN CERTIFICATE-----\nMIIDLDCCAhSgAwIBAgIBADANBgkqhkiG9w0BAQUFADA8MQwwCgYDVQQDDANnZWQx\nFzAVBgoJkiaJk/IsZAEZFgdfYWVyaWVfMRMwEQYKCZImiZPyLGQBGRYDb3JnMB4X\nDTEwMDkxNjE0NDg1MVoXDTExMDkxNjE0NDg1MVowPDEMMAoGA1UEAwwDZ2VkMRcw\nFQYKCZImiZPyLGQBGRYHX2FlcmllXzETMBEGCgmSJomT8ixkARkWA29yZzCCASIw\nDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALy//BFxC1f/cPSnwtJBWoFiFrir\nh7RicI+joq/ocVXQqI4TDWPyF/8tqkvt+rD99X9qs2YeR8CU/YiIpLWrQOYST70J\nvDn7Uvhb2muFVqq6+vobeTkILBEO6pionWDG8jSbo3qKm1RjKJDwg9p4wNKhPuu8\nKGue/BFb67KflqyApPmPeb3Vdd9clspzqeFqp7cUBMEpFS6LWxy4Gk+qvFFJBJLB\nBUHE/LZVJMVzfpC5Uq+QmY7B+FH/QqNndn3tOHgsPadLTNimuB1sCuL1a4z3Pepd\nTeLBEFmEao5Dk3K/Q8o8vlbIB/jBDTUx6Djbgxw77909x6gI9doU4LD5XMcCAwEA\nAaM5MDcwCQYDVR0TBAIwADALBgNVHQ8EBAMCBLAwHQYDVR0OBBYEFJeoGkOr9l4B\n+saMkW/ZXT4UeSvVMA0GCSqGSIb3DQEBBQUAA4IBAQBG2KObvYI2eHyyBUJSJ3jN\nvEnU3d60znAXbrSd2qb3r1lY1EPDD3bcy0MggCfGdg3Xu54z21oqyIdk8uGtWBPL\nHIa9EgfFGSUEgvcIvaYqiN4jTUtidfEFw+Ltjs8AP9gWgSIYS6Gr38V0WGFFNzIH\naOD2wmu9oo/RffW4hS/8GuvfMzcw7CQ355wFR4KB/nyze+EsZ1Y5DerCAagMVuDQ\nU0BLmWDFzPGGWlPeQCrYHCr+AcJz+NRnaHCKLZdSKj/RHuTOt+gblRex8FAh8NeA\ncmlhXe46pZNJgWKbxZah85jIjx95hR8vOI+NAM5iH9kOqK13DrxacTKPhqj5PjwF\n-----END CERTIFICATE-----\n"]
  s.date = %q{2011-01-19}
  s.description = %q{This is the extension library to access a PostgreSQL database from Ruby.
This library works with PostgreSQL 7.4 and later.}
  s.email = ["ruby-pg@j-davis.com", "ged@FaerieMUD.org"]
  s.extensions = ["ext/extconf.rb"]
  s.extra_rdoc_files = ["ChangeLog", "README", "README.ja", "README.OS_X", "README.windows", "LICENSE"]
  s.files = ["Rakefile", "ChangeLog", "README", "README.ja", "README.OS_X", "README.windows", "LICENSE", "spec/m17n_spec.rb", "spec/pgconn_spec.rb", "spec/pgresult_spec.rb", "spec/lib/helpers.rb", "lib/pg.rb", "ext/compat.c", "ext/pg.c", "ext/compat.h", "ext/pg.h", "ext/extconf.rb", "rake/191_compat.rb", "rake/dependencies.rb", "rake/documentation.rb", "rake/helpers.rb", "rake/hg.rb", "rake/manual.rb", "rake/packaging.rb", "rake/publishing.rb", "rake/style.rb", "rake/svn.rb", "rake/testing.rb", "rake/verifytask.rb", "./README.ja", "./README.OS_X", "./README.windows", "./GPL", "./BSD", "./Contributors", "Rakefile.local", "spec/data/expected_trace.out", "spec/data/random_binary_data"]
  s.homepage = %q{http://bitbucket.org/ged/ruby-pg/}
  s.licenses = ["Ruby", "GPL", "BSD"]
  s.rdoc_options = ["--tab-width=4", "--show-hash", "--include", ".", "--main=README", "--title=pg"]
  s.require_paths = ["lib", "ext"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.7")
  s.requirements = ["PostgreSQL >=7.4"]
  s.rubygems_version = %q{1.4.1}
  s.summary = %q{A Ruby interface to the PostgreSQL RDBMS}
  s.test_files = ["spec/m17n_spec.rb", "spec/pgconn_spec.rb", "spec/pgresult_spec.rb", "spec/lib/helpers.rb", "spec/data/expected_trace.out", "spec/data/random_binary_data"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
