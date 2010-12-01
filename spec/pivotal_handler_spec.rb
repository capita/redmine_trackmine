require 'spec_helper'

describe 'The Pivotal Handler' do
  include Rack::Test::Methods

  def app
    PivotalHandler
  end

  before do
    #@user = Factory(:tracker_activity)
    @tracker_activity = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<activity>\n  <id type=\"integer\">38057455</id>\n  <version type=\"integer\">17</version>\n  <event_type>story_update</event_type>\n  <occurred_at type=\"datetime\">2010/11/27 14:44:58 UTC</occurred_at>\n  <author>Piotr Brudny</author>\n  <project_id type=\"integer\">152369</project_id>\n  <description>Piotr Brudny edited &quot;Szafa gra&quot;</description>\n  <stories>\n    <story>\n      <id type=\"integer\">6799765</id>\n      <url>http://www.pivotaltracker.com/services/v3/projects/152369/stories/6799765</url>\n      <current_state>unstarted</current_state>\n    </story>\n  </stories>\n</activity>\n\n"
  end
  
  it "says hello ziom" do
    get '/hello/ziom'
    last_response.should be_ok
    last_response.body.should == 'Hello ziom'
  end

  it "shouldn't respond for redmine root page" do
    get '/'
    last_response.should_not be_ok
  end

  it "should respond for post pivotal message" do
    post 'pivotal_message.xml', @tracker_activity
    last_response.should be_ok
    last_response.status.should == 200
  end
  
end

