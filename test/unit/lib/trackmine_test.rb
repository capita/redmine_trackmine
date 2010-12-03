require File.dirname(__FILE__) + '/../../test_helper'

class TrackmineTest < Test::Unit::TestCase

  def fixture_path
    File.dirname(__FILE__) + '/../../fixtures/projects.xml'
  end

  context 'Trackmine' do
    setup do
      FakeWeb.allow_net_connect = false
      FakeWeb.register_uri(:get, "http://www.pivotaltracker.com/services/v3/projects", :body => File.read(fixture_path), :content_type => "text/xml")
    end

    context '.projects method' do
      setup { @projects = Trackmine.projects }  
      should "return an array of available projects" do
        assert @projects.kind_of?(Array)
      end
    end
  end

end


