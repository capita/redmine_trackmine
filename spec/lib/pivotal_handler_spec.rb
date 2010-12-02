require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'The Pivotal Handler' do
  include Rack::Test::Methods

  def app
    PivotalHandler
  end

  before do
    #@user = Factory(:tracker_activity)
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

