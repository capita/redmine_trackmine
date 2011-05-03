# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{fast_context}
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Pratik Naik"]
  s.date = %q{2010-04-22}
  s.email = %q{adam@pohorecki.pl}
  s.extra_rdoc_files = ["README"]
  s.files = [".gitignore", "MIT-LICENSE", "README", "Rakefile", "VERSION", "lib/fast_context.rb", "lib/init.rb"]
  s.homepage = %q{http://github.com/psyho/fast_context}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.4.1}
  s.summary = %q{This is a gem version of the fast_context plugin}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<shoulda>, [">= 0"])
    else
      s.add_dependency(%q<shoulda>, [">= 0"])
    end
  else
    s.add_dependency(%q<shoulda>, [">= 0"])
  end
end
