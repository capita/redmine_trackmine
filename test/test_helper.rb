# Load test_helper from Redmine main project
require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')
require 'fakeweb'
require 'shoulda'
require 'fast_context'
require 'factory_girl'
require 'test/unit'
require 'rack/test'

# load factories manually. Otherwise load it from redmine app.
if (!Factory.factories || Factory.factories.empty?)
  Dir.glob(File.dirname(__FILE__) + "/factories/*.rb").each do |factory|
    require factory
  end
end

# Ensure that we are using the temporary fixture path for Redmin
Engines::Testing.set_fixture_path
set :environment, :test

# Establishing fakeweb for PivotalTracker
module FakeTracker

  # Constant to load a correct fixture project
  PROJECT_ID = 102622 

  # Labels taken from stories.xml fixture. Make sure there are the same.
  LABELS = ['shields','transporter']

  class << self

    # Path for Trackmine fixtures only!
    def fixture_path(fixture)
     File.dirname(__FILE__) + "/fixtures/#{fixture}.xml"
    end

    def setup
      FakeWeb.allow_net_connect = false
      FakeWeb.register_uri(:post, "https://www.pivotaltracker.com/services/v3/tokens/active", :body => File.read(fixture_path('token')), :content_type => "text/xml")
      FakeWeb.register_uri(:get, "http://www.pivotaltracker.com/services/v3/projects", :body => File.read(fixture_path('projects')), :content_type => "text/xml")
      FakeWeb.register_uri(:get, "http://www.pivotaltracker.com/services/v3/projects/#{PROJECT_ID}", :body => File.read(fixture_path('project')), :content_type => "text/xml")
      FakeWeb.register_uri(:get, "http://www.pivotaltracker.com/services/v3/projects/#{PROJECT_ID}/memberships", :body => File.read(fixture_path('memberships')), :content_type => "text/xml")
      FakeWeb.register_uri(:get, "http://www.pivotaltracker.com/services/v3/projects/#{PROJECT_ID}/stories", :body => File.read(fixture_path('stories')), :content_type => "text/xml")
    end
  end 
end
