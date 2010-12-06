require File.dirname(__FILE__) + '/../../test_helper'

class TrackmineTest < Test::Unit::TestCase

  context 'Trackmine' do
    setup do
      FakeTracker.setup
    end

    context '.projects method' do
      setup { @projects = Trackmine.projects }  

      should "return an array of available projects" do
        assert @projects.kind_of? Array
      end
  
      should "be a project instance" do
        assert @projects.first.instance_of? PivotalTracker::Project
      end
    end

    #TODO: set_token

    context '.project_labels(tracker_project_id)' do
      setup { @labels = Trackmine.project_labels(FakeTracker::PROJECT_ID) }  

      should "return an array" do
        assert @labels.kind_of? Array
      end
      
      should "return an array of project labels" do
        assert @labels == FakeTracker::LABELS
      end
    end
  
    context '.get_authors_email(activity) method' do
      context 'with wrong activity format' do
        setup { @activity = {'author' => 'Test Suite Access'} }

        should "raise an error" do
          assert_raise Trackmine::WrongActivityData  do
            Trackmine.get_authors_email(@activity)
          end
        end
      end
    end
      
    context 'with correct activity' do
      setup { @activity = {'project_id' => 102622, 'author' => 'Test Suite Access'} }

      should "should return authors email" do
        assert_equal Trackmine.get_authors_email(@activity), 'pivotal-tracker-api-gem@quagility.com'
      end
    end
  end
end


