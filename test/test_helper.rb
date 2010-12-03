# Load test_helper from Redmine main project
require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')
require 'fakeweb'
require 'shoulda'
require 'factory_girl'
require 'test/unit'
require 'rack/test'

# load factories manually. Otherwise load it from redmine app.
if (!Factory.factories || Factory.factories.empty?)
  Dir.glob(File.dirname(__FILE__) + "/factories/*.rb").each do |factory|
    require factory
  end
end

# Ensure that we are using the temporary fixture path
Engines::Testing.set_fixture_path
set :environment, :test


