# Load test_helper from Redmine main project
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')
require 'bundler'
Bundler.setup(:default, :spec)
require 'factory_girl'
require 'rack/test'
require 'vcr'

# load factories manually. Otherwise load it from redmine app.
# if (!FactoryGirl.factories || FactoryGirl.factories.empty?)
  Dir.glob(File.dirname(__FILE__) + "/factories/*.rb").each do |factory|
    require factory
  end

RSpec.configure do |config|
  config.color = true
  config.tty = true
  config.formatter = :documentation
  config.include FactoryGirl::Syntax::Methods
  config.treat_symbols_as_metadata_keys_with_true_values = true
end

VCR.configure do |c|
  c.cassette_library_dir = File.dirname(__FILE__) + '/cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
end

def json_path(fixture)
  File.dirname(__FILE__) + "/fixtures/#{fixture}.json"
end


def fixtures
  %i(
      users
      email_addresses
      projects
      custom_fields
      custom_fields_projects
      custom_fields_trackers
      custom_values
      trackers
      projects_trackers
      issue_statuses
      issue_priorities
      issues
      mappings
    )
end

ActiveRecord::FixtureSet.create_fixtures(File.dirname(__FILE__) + '/fixtures/', fixtures)
