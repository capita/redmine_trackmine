require File.dirname(__FILE__) + '/../../test_helper'

class PivotalHandlerTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    PivotalHandler
  end
  
  context 'A Pivotal Handler' do
    setup do
      #FakeTracker.setup
      activity_hash = {"author"=>"Piotr Brudny", "id"=>38057455, "version"=>17, "description"=>"Piotr Brudny edited \"Szafa gra\"",  "stories"=>{"story"=>{"current_state"=>"unstarted", "url"=>"http://www.pivotaltracker.com/services/v3/projects/152369/stories/6799765", "id"=>6799765}}}
      activity_hash['project_id'] = 152369
      activity_hash['event_type'] = "story_update"
      activity_hash['occurred_at'] = Time.now
      @tracker_activity = activity_hash.to_xml(:root => 'activity')
    end
  
    should "not respond for a redmine root page" do
      get '/'
      assert !last_response.ok?
    end

    should "respond for post pivotal message" do
      post 'pivotal_message.xml', @tracker_activity
      assert last_response.ok?
      assert_equal last_response.status, 200
    end
  end  
end

