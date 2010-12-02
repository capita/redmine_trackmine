require File.dirname(__FILE__) + '/../../test_helper'

class PivotalHandlerTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    PivotalHandler
  end
  
  context 'A Pivotal Tracker handler' do
    setup do
      @tracker_activity = 
      '<?xml version="1.0" encoding="UTF-8"?>
        <activity>
          <id type="integer">38057455</id>
          <version type="integer">17</version>
            <event_type>story_update</event_type>
            <occurred_at type="datetime">2010/11/27 14:44:58 UTC</occurred_at>
            <author>Piotr Brudny</author>
            <project_id type="integer">152369</project_id>
            <description>Piotr Brudny edited &quot;Szafa gra&quot;</description>
            <stories>
              <story>
                <id type="integer">6799765</id>
                <url>http://www.pivotaltracker.com/services/v3/projects/152369/stories/6799765</url>
                <current_state>unstarted</current_state>
              </story>
            </stories>
        </activity>'
    end
  
    should "says hello ziom" do
      get '/hello/ziom'
      assert last_response.ok?
      assert_equal last_response.body, 'Hello ziom'
    end

    should "not respond for redmine root page" do
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

