require File.dirname(__FILE__) + '/../../test_helper'

class TrackmineTest < Test::Unit::TestCase

  def setup
    @activity_hash = { "author" => "Test Suite Access", 
                       "id" => 38057455,
                       "project_id" => 102622, 
                       "occurred_at" => Time.now,
                       "event_type" => "story_update",
                       "version" => 17, 
                       "description" => "Test Suite Access started story",  
                       "stories" => {"story" => {"current_state" => "started", 
                                                 "url" => "http://www.pivotaltracker.com/services/v3/projects/102622/stories/4460116", 
                                                 "id" => 4460116 }}}

    @sample_story = { "name" => "More power to shields", 
                      "current_state" => "accepted", 
                      "requested_by" => "James Kirk", 
                      "project_id" => 102622, 
                      "url" => "http://www.pivotaltracker.com/story/show/4460116", 
                      "id" => 4460116, 
                      "story_type" => "feature", 
                      "description" => "It is a basic description", 
                      "labels" => "shields,transporter", 
                      "owned_by" => "Test Suite Access", 
                      "estimate" => 1 }
    
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
  
    context '.get_user_email(project_id, name)' do
      context 'with wrong attributes' do
        should "raise an error" do
          assert_raise(Trackmine::WrongActivityData) { Trackmine.get_user_email(1, 'noname') }
        end
      end

      context 'with correct attributes' do
        should("return authors email") do 
          assert_equal Trackmine.get_user_email(102622, 'Jon Mischo'), 'jmischo@quagility.com' 
        end
      end
    end   
  
    context 'reading activity' do
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
      
      context 'get_story(activity)' do
        context 'having correct activity data' do
        setup { @activity = { 'project_id' => 102622,
                              'stories' => { 'story' => { 'id' => 4460116 } } } }
          should "a return Story object" do
            assert Trackmine.get_story(@activity).kind_of? PivotalTracker::Story 
          end 
        end

        context 'having wrong activity data' do
          setup { @activity = { 'project_id' => 90909,
                                'stories' => { 'story' => { 'id' => 90909 } } } }
          should('raise an error') do
            assert_raise(Trackmine::WrongActivityData) { Trackmine.get_story(@activity)}
          end
        end
      end

      fast_context 'starting a story with 2 labels' do
        setup do 
          @activity_hash['stories']['story']['id'] = 4460116
          @mapping = Factory.create :mapping, 
                                    :tracker_project_id => @activity_hash['project_id'], 
                                    :label => ''
#          FakeWeb.register_uri( :get,
#                               "http://www.pivotaltracker.com/services/v3/projects/#{@activity_hash['project_id']}/stories/#{@activity_hash['stories']['story']['id']}",
#                               :body => @sample_story.to_xml(:root => 'story'),
#                               :content_type => "text/xml")
         end

        should 'create a proper Feature issue' do
          issue = Trackmine.create_issues(@activity_hash)[0]

          assert issue.instance_of? Issue
          assert_equal "More power to shields", issue.subject
          assert_equal "http://www.pivotaltracker.com/story/show/4460116" +"\r\n"+ "It is a basic description", issue.description
          assert_equal "Feature", issue.tracker.name
          assert_equal "Accepted", issue.status.name  
          assert_equal 4, issue.estimated_hours
          assert_equal 'admin@somenet.foo', issue.author.mail
          assert_equal @activity_hash['stories']['story']['id'], issue.custom_field_values.select{|cv| cv.custom_field.name=="Pivotal Story ID"}.first.try(:value)
          assert_equal 5, issue.journals.size
        end
  
#        should 'create a proper Bug issue' do
#          @activity_hash['stories']['story']['story_type'] = "bug" 
#          @activity_hash['stories']['story']['name'] = "Testing API Bug"
#          @activity_hash['stories']['story']['estimate'] = ''
#          issue = Trackmine.create_issues(@activity_hash)

#          assert issue.instance_of? Issue
#          assert_equal @activity_hash['stories']['story']['name'], issue.subject
#          assert_equal @activity_hash['stories']['story']['url'] +"\r\n"+@activity_hash['description'], issue.description
#          assert_equal "Bug", issue.tracker.name
#          assert_equal "Accepted", issue.status.name  
#          assert issue.estimated_hours.nil?
#          assert_equal @activity_hash['stories']['story']['id'], issue.custom_field_values.select{|cv| cv.custom_field.name=="Pivotal Story ID"}.first.try(:value)
#        end

#        should 'create a proper Support issue' do
#          @activity_hash['stories']['story']['story_type'] = "chore" #bug,chore
#          @activity_hash['stories']['story']['name'] = "Testing API Support"
#          @activity_hash['stories']['story']['estimate'] = ''

#          issue = Trackmine.create_issue( @activity_hash, @label )
#          assert issue.instance_of? Issue
#          assert_equal @activity_hash['stories']['story']['name'], issue.subject
#          assert_equal @activity_hash['stories']['story']['url'] +"\r\n"+@activity_hash['description'], issue.description
#          assert_equal "Support", issue.tracker.name
#          assert_equal "Accepted", issue.status.name  
#          assert issue.estimated_hours.nil?
#          assert_equal @activity_hash['stories']['story']['id'], issue.custom_field_values.select{|cv| cv.custom_field.name=="Pivotal Story ID"}.first.try(:value)
#        end
      end

#      fast_context 'create_story with a label' do
#        setup do 
#          @label = "Label1"
#          @mapping = Factory.create :mapping, 
#                                    :tracker_project_id => @activity_hash['project_id'], 
#                                    :label => @label 
#        end

#        should 'create a proper Feature issue' do
#          @activity_hash['stories']['story']['name'] = "Testing API feature"
#          @activity_hash['stories']['story']['story_type'] = "feature" #bug,chore
#          @activity_hash['stories']['story']['estimate'] = 2
#          issue = Trackmine.create_issue(@activity_hash, @label)

#          assert issue.instance_of? Issue
#          assert_equal @activity_hash['stories']['story']['name'], issue.subject
#          assert_equal @activity_hash['stories']['story']['url'] +"\r\n"+@activity_hash['description'], issue.description
#          assert_equal "Feature", issue.tracker.name
#          assert_equal "Accepted", issue.status.name  
#          assert_equal 4, issue.estimated_hours
#          assert_equal @activity_hash['stories']['story']['id'], issue.custom_field_values.select{|cv| cv.custom_field.name=="Pivotal Story ID"}.first.try(:value)
#        end

#        should 'create a proper Bug issue' do
#          @activity_hash['stories']['story']['story_type'] = "bug" 
#          @activity_hash['stories']['story']['name'] = "Testing API Bug"
#          @activity_hash['stories']['story']['estimate'] = ''

#          issue = Trackmine.create_issue( @activity_hash, @label )
#          assert issue.instance_of? Issue
#          assert_equal @activity_hash['stories']['story']['name'], issue.subject
#          assert_equal @activity_hash['stories']['story']['url'] +"\r\n"+@activity_hash['description'], issue.description
#          assert_equal "Bug", issue.tracker.name
#          assert_equal "Accepted", issue.status.name  
#          assert issue.estimated_hours.nil?
#          assert_equal @activity_hash['stories']['story']['id'], issue.custom_field_values.select{|cv| cv.custom_field.name=="Pivotal Story ID"}.first.try(:value)
#        end

#        should 'create a proper Support issue' do
#          @activity_hash['stories']['story']['story_type'] = "chore" 
#          @activity_hash['stories']['story']['name'] = "Testing API Support"
#          @activity_hash['stories']['story']['estimate'] = ''

#          issue = Trackmine.create_issue(@activity_hash, @label)
#          assert issue.instance_of? Issue
#          assert_equal @activity_hash['stories']['story']['name'], issue.subject
#          assert_equal @activity_hash['stories']['story']['url'] +"\r\n"+@activity_hash['description'], issue.description
#          assert_equal "Support", issue.tracker.name
#          assert_equal "Accepted", issue.status.name  
#          assert issue.estimated_hours.nil?
#          assert_equal @activity_hash['stories']['story']['id'], issue.custom_field_values.select{|cv| cv.custom_field.name=="Pivotal Story ID"}.first.try(:value)
#        end
#      end

    end 
  end
end


