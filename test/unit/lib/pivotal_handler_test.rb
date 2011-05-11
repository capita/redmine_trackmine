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

  end  
end

