require File.dirname(__FILE__) + '/../../test_helper'

class PivotalHandlerTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    PivotalHandler
  end
  
  context 'A Pivotal Handler' do
    setup { FakeTracker.setup }

    should "not respond for a redmine root page" do
      get '/'
      assert !last_response.ok?
    end
  
    context 'POST /pivotal_activity.xml' do 
      context 'having a correct activity message with Redmine mapping' do
        setup do 
          @tracker_activity = File.read( File.dirname(__FILE__) + "/../../fixtures/activity.xml") 
          Factory.create :mapping, :tracker_project_id => 102622, :label => 'shields'
          Factory.create :mapping, :tracker_project_id => 102622, :label => 'transporter'
        end
    
        should "return OK status" do
          post 'pivotal_activity.xml', @tracker_activity
          assert last_response.ok?
          assert_equal last_response.status, 200
        end
      end  

      context "with invalid activity message" do
        setup { post '/pivotal_activity.xml', {}.to_xml}
        should("return accepted status") { assert_equal 202, last_response.status}
      end
      
    end
  end  
end

