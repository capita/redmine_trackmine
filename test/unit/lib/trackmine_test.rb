require File.dirname(__FILE__) + '/../../test_helper'

class TrackmineTest < Test::Unit::TestCase

  def setup
    @activity_hash = { "author"=>"Test Suite Access", 
                       "id"=>38057455,
                       "project_id"=>102622, 
                       "occurred_at" => Time.now,
                       "version"=>17, 
                       "description"=>"Edited sth",  
                       "stories"=>{"story"=>{"current_state"=>"unstarted", 
                                                       "url"=>"http://www.pivotaltracker.com/services/v3/projects/152369/stories/6799765", 
                                                       "id"=>6799765}}}
    @tracker_activity = @activity_hash.to_xml(:root => 'activity')
    FakeTracker.setup
  end        

  context 'Trackmine' do
    context '.projects method' do
      setup { @projects = Trackmine.projects }  
      should("return an array of available projects") { assert @projects.kind_of? Array }
      should("be a project instance") { assert @projects.first.instance_of? PivotalTracker::Project }
    end

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
        should("return authors email"){ assert_equal Trackmine.get_authors_email(@activity), 'admin@somenet.foo' }
      end
    end   
  
    context 'reading activity' do
      context 'having event_type different than "story_create" or "story_update"' do
        should "raise an error" do
          assert_raise(Trackmine::WrongActivityData) { Trackmine.read_activity @tracker_activity }
        end
      end
      
      context '.get_mapping(tracker_project_id, label)' do
        context 'when no Redmine project mapped' do
          should("raise an error") do 
            assert_raise(Trackmine::MissingTrackmineMapping) { Trackmine.get_mapping(10,'match')}
          end
        end

        context 'when there is a mapping for the Redmine project' do
          setup { @mapping = Factory.create(:mapping, :label => '') }
          should('return a mapping object') { assert_equal (Trackmine.get_mapping( @mapping.tracker_project_id ,'' )), @mapping }                            
        end
      end
      context 'create_story' do
        setup do 
          @mapping = Factory.create(:mapping, :tracker_project_id => @activity_hash['project_id'], :label => '') 
         end
        should 'create an issue' do
          assert Trackmine.create_issue(@activity_hash).instance_of? Issue
        end
      end
    end 
  end
end


