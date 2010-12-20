# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{hirb}
  s.version = "0.3.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.5") if s.respond_to? :required_rubygems_version=
  s.authors = ["Gabriel Horner"]
  s.date = %q{2010-11-08}
  s.description = %q{Hirb provides a mini view framework for console applications and uses it to improve irb's default inspect output. Given an object or array of objects, hirb renders a view based on the object's class and/or ancestry. Hirb offers reusable views in the form of helper classes. The two main helpers, Hirb::Helpers::Table and Hirb::Helpers::Tree, provide several options for generating ascii tables and trees. Using Hirb::Helpers::AutoTable, hirb has useful default views for at least ten popular database gems i.e. Rails' ActiveRecord::Base. Other than views, hirb offers a smart pager and a console menu. The smart pager only pages when the output exceeds the current screen size. The menu is used in conjunction with tables to offer two dimensional menus.}
  s.email = %q{gabriel.horner@gmail.com}
  s.extra_rdoc_files = ["README.rdoc", "LICENSE.txt"]
  s.files = ["lib/bond/completions/hirb.rb", "lib/hirb/console.rb", "lib/hirb/dynamic_view.rb", "lib/hirb/formatter.rb", "lib/hirb/helpers/auto_table.rb", "lib/hirb/helpers/object_table.rb", "lib/hirb/helpers/parent_child_tree.rb", "lib/hirb/helpers/table/filters.rb", "lib/hirb/helpers/table/resizer.rb", "lib/hirb/helpers/table.rb", "lib/hirb/helpers/tree.rb", "lib/hirb/helpers/vertical_table.rb", "lib/hirb/helpers.rb", "lib/hirb/import_object.rb", "lib/hirb/menu.rb", "lib/hirb/pager.rb", "lib/hirb/string.rb", "lib/hirb/util.rb", "lib/hirb/version.rb", "lib/hirb/view.rb", "lib/hirb/views/couch_db.rb", "lib/hirb/views/misc_db.rb", "lib/hirb/views/mongo_db.rb", "lib/hirb/views/orm.rb", "lib/hirb/views/rails.rb", "lib/hirb/views.rb", "lib/hirb.rb", "lib/ripl/hirb.rb", "test/auto_table_test.rb", "test/console_test.rb", "test/dynamic_view_test.rb", "test/formatter_test.rb", "test/hirb_test.rb", "test/import_test.rb", "test/menu_test.rb", "test/object_table_test.rb", "test/pager_test.rb", "test/resizer_test.rb", "test/table_test.rb", "test/test_helper.rb", "test/tree_test.rb", "test/util_test.rb", "test/view_test.rb", "test/views_test.rb", "LICENSE.txt", "CHANGELOG.rdoc", "README.rdoc", "test/deps.rip", "Rakefile", ".gemspec"]
  s.homepage = %q{http://tagaholic.me/hirb/}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{tagaholic}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{A mini view framework for console/irb that's easy to use, even while under its influence.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bacon>, [">= 1.1.0"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
      s.add_development_dependency(%q<mocha-on-bacon>, [">= 0"])
      s.add_development_dependency(%q<bacon-bits>, [">= 0"])
    else
      s.add_dependency(%q<bacon>, [">= 1.1.0"])
      s.add_dependency(%q<mocha>, [">= 0"])
      s.add_dependency(%q<mocha-on-bacon>, [">= 0"])
      s.add_dependency(%q<bacon-bits>, [">= 0"])
    end
  else
    s.add_dependency(%q<bacon>, [">= 1.1.0"])
    s.add_dependency(%q<mocha>, [">= 0"])
    s.add_dependency(%q<mocha-on-bacon>, [">= 0"])
    s.add_dependency(%q<bacon-bits>, [">= 0"])
  end
end
