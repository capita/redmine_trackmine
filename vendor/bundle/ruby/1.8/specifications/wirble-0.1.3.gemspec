# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{wirble}
  s.version = "0.1.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Paul Duncan"]
  s.autorequire = %q{wirble}
  s.date = %q{2009-05-30}
  s.description = %q{Handful of common Irb features, made easy.}
  s.email = %q{pabs@pablotron.org}
  s.files = ["_irbrc", "wirble.gemspec", "Rakefile", "setup.rb", "README", "lib/wirble.rb", "ChangeLog", "COPYING"]
  s.homepage = %q{http://pablotron.org/software/wirble/}
  s.rdoc_options = ["--title", "Wirble 0.1.3 API Documentation", "--webcvs", "http://hg.pablotron.org/wirble", "lib/wirble.rb", "README"]
  s.require_paths = ["lib"]
  s.requirements = ["none"]
  s.rubyforge_project = %q{pablotron}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Handful of common Irb features, made easy.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
