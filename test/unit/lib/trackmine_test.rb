require File.dirname(__FILE__) + '/../../test_helper'

class TrackmineTest < Test::Unit::TestCase

  context 'Trackmine' do
    setup { FakeTracker.setup }

    context '.projects method' do
      setup { @projects = Trackmine.projects }  

      should("return an array of available projects") { assert @projects.kind_of? Array }
      should("be a project instance") { assert @projects.first.instance_of? PivotalTracker::Project }
    end

    #TODO: set_token

    context '.project_labels(tracker_project_id)' do
      setup { @labels = Trackmine.project_labels(FakeTracker::PROJECT_ID) }  

      should("return an array") { assert @labels.kind_of? Array }
      should("return an array of project labels") { assert @labels == FakeTracker::LABELS }
    end
  
    context '.get_authors_email(activity)' do
      context 'with wrong activity format' do
        setup { @activity = {'author' => 'Test Suite Access'} }

        should "raise an error" do
          assert_raise(Trackmine::WrongActivityData) { Trackmine.get_authors_email(@activity) }
        end
      end

      context 'with correct activity' do
        setup { @activity = {'project_id' => 102622, 'author' => 'Test Suite Access'} }

        should("should return authors email"){ assert_equal Trackmine.get_authors_email(@activity), 'pivotal-tracker-api-gem@quagility.com' }
      end
    end   
  

    context 'reading activity' do
      setup do
        @activity_hash = {"author"=>"Test Suite Access", "id"=>38057455, "version"=>17, "description"=>"Edited sth",  "stories"=>{"story"=>{"current_state"=>"unstarted", "url"=>"http://www.pivotaltracker.com/services/v3/projects/152369/stories/6799765", "id"=>6799765}}}
        @activity_hash['project_id'] = 152369
        @activity_hash['occurred_at'] = Time.now
        @tracker_activity = @activity_hash.to_xml(:root => 'activity')
      end          
      
      context 'having event_type different than "story_create" or "story_update"' do
        should "raise an error" do
          assert_raise(Trackmine::WrongActivityData) { Trackmine.read_activity @tracker_activity }
        end
      end
      
      context '.get_mapping(tracker_project_id)' do
        context 'when no Redmine project mapped' do
          should("raise an error") do 
            assert_raise(Trackmine::MissingTrackmineMapping) { Trackmine.get_mapping()}
          end
        end
        context 'when there is a mapping for the Redmine project' do
          context 'and a Tracker project' do
          end
          context 'and a Tracker label' do
          end
        end
      end

    end 
  end
end


