# Load test_helper from Redmine main project
require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')
require 'bundler'
Bundler.setup(:default, :test)
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

# Establishing fakeweb for PivotalTracker
module FakeTracker

  # Constant to load a correct fixture project
  PROJECT_ID = 102622 
  STORY_ID = 4460116

  # Labels taken from stories.xml fixture.
  LABELS = ['shields','transporter']

  class << self

    # Path for Trackmine fixtures only!
    def fixture_path(fixture)
     File.dirname(__FILE__) + "/fixtures/#{fixture}.xml"
    end

    def setup
      FakeWeb.allow_net_connect = false
      projects_url = "http://www.pivotaltracker.com/services/v3/projects"

      [[:put, %r|http://www.pivotaltracker.com/services/v3/projects/|, 'put_response'],
       [:post, "https://www.pivotaltracker.com/services/v3/tokens/active",    'token'],
       [:get, projects_url,                                                'projects'],
       [:get, projects_url + "/#{PROJECT_ID}",                              'project'],
       [:get, projects_url + "/#{PROJECT_ID}/memberships",              'memberships'],
       [:get, projects_url + "/#{PROJECT_ID}/stories",                      'stories'],
       [:get, projects_url + "/#{PROJECT_ID}/stories/#{STORY_ID}",            'story'],
       [:get, projects_url + "/#{PROJECT_ID}/stories/1",                'story_bug_1'],
       [:get, projects_url + "/#{PROJECT_ID}/stories/2",              'story_chore_2'],
       [:get, projects_url + "/#{PROJECT_ID}/stories/3",     'story_feature_labels_3'],
       [:get, projects_url + "/#{PROJECT_ID}/stories/#{STORY_ID}/notes",    'notes_1'],
       [:get, projects_url + "/#{PROJECT_ID}/stories/1/notes",              'notes_1'],
       [:get, projects_url + "/#{PROJECT_ID}/stories/2/notes",              'notes_2'],
       [:get, projects_url + "/#{PROJECT_ID}/stories/3/notes",              'notes_2']
      ].each{|fw| FakeWeb.register_uri(fw[0], fw[1], :body => File.read(fixture_path(fw[2])), 
                                                     :content_type => "text/xml" )}
    end
  end 
end
