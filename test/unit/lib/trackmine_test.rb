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
                       "stories" => {"story" => {"url" => "http://www.pivotaltracker.com/services/v3/projects/102622/stories/4460116", 
                                                 "id" => 4460116 }}}

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
  
    context '.get_mapping(tracker_project_id, label)' do
      context 'when no Redmine project mapped' do
        should("not raise an error") do 
          assert_nothing_raised(Trackmine::MissingTrackmineMapping) { Trackmine.get_mapping(10,'match')}
        end
      end

      context 'when there is a mapping for the Redmine project' do
        setup { @mapping = Factory.create(:mapping, :label => '') }
        should('return a mapping object') { assert_equal (Trackmine.get_mapping( @mapping.tracker_project_id ,'' )), @mapping }                            
      end
    end
      
    context '.get_story(activity)' do
      context 'having correct activity data' do
        setup { @activity = { 'project_id' => 102622,
                              'stories' => { 'story' => { 'id' => 4460116 } } } }
        should "a return Story object" do
          assert Trackmine.get_story(@activity).kind_of? PivotalTracker::Story 
        end 
      end

      context 'having wrong activity data' do
        setup do 
          @activity = { 'project_id' => 102622,
                              'stories' => { 'story' => { 'id' => 90909 } } } 
          FakeWeb.register_uri(:get, "https://www.pivotaltracker.com/services/v3/projects/102622/stories/90909" , 
                               :body => '', 
                               :content_type => "text/plain" )
        end
        should('raise an error') do
          assert_raise(Trackmine::WrongActivityData) { Trackmine.get_story(@activity)}
        end
      end
    end

    fast_context '.create_issues method' do
      setup do 
        @activity_hash['stories']['story']['id'] = 1  
        Factory.create :mapping, :tracker_project_id => @activity_hash['project_id'], :label => ''
        @old_count= StoryProject.count
        @issue = Trackmine.create_issues(@activity_hash)[0]
      end
      
      should('create one StoryProject') { assert StoryProject.count - @old_count == 1 }
      should 'create a proper Feature issue' do
        assert @issue.instance_of? Issue
        assert_equal "Story 1", @issue.subject
        assert_equal "http://www.pivotaltracker.com/story/show/1" +"\r\n"+ "Description 1", @issue.description
        assert_equal "Bug", @issue.tracker.name
        assert_equal "Accepted", @issue.status.name  
        assert_equal 0, @issue.estimated_hours
        assert_equal 'admin@somenet.foo', @issue.author.mail
        assert_equal @activity_hash['stories']['story']['id'], @issue.pivotal_story_id
        assert_equal 5, @issue.journals.size
      end
    end
    
    context '.update_issues(issues,tracker_project_id, params)' do
      context 'with no mapping' do
        setup do
          @issue = Factory(:issue)
          @tpid = Mapping.all.collect{|t| t.tracker_project_id}.max + 1
        end

        should('not raise an error') do
          assert_nothing_raised (Trackmine::MissingTrackmineMapping) { Trackmine.update_issues([@issue], @tpid, {})}
        end
      end

      context 'with mapping' do
        setup do 
          @issue = Factory(:issue)
          Factory(:mapping, :project_id => 1, :tracker_project_id => 888 )
        end

        should 'update issues description' do
          Trackmine.update_issues( [@issue], 888, {:description => 'new d'} )
          assert_equal 'new d', @issue.description
        end

        should 'update issues subject' do
          Trackmine.update_issues( [@issue], 888, {:subject => 'new s'} )
          assert_equal 'new s', @issue.subject
        end
      end
    end
    
    fast_context 'finish_story' do
      setup do 
        @story_id = StoryProject.first.story_id
        @wrong_id = -1 
      end

      should("get response with a current_state 'finished'") do
        assert_equal "finished", Trackmine.finish_story(@story_id).current_state
      end

      should("raise an errors when wrong story_id given") do
        assert_raise(Trackmine::PivotalTrackerError) { Trackmine.finish_story(@wrong_id) }
      end
    end

    fast_context 'starting a story with one label' do
      setup do
        @activity_hash['stories']['story'] = { 'id' => 2,
                                               'url' => "http://www.pivotaltracker.com/services/v3/projects/102622/stories/4460116",
                                               'current_state' => 'started' } 
        @story = @activity_hash['stories']['story']
        Factory(:mapping, :project_id => 1, :tracker_project_id => @activity_hash['project_id'], :label => 'education')
        @issue_count = Issue.count    
        Trackmine.read_activity @activity_hash
        @issue = Issue.last
      end

      should('create 1 issue') { assert Issue.count - @issue_count == 1 }
      should('set issues subject') { assert_equal "Story 2", @issue.subject}    
      should('set issues description') { assert_equal "http://www.pivotaltracker.com/story/show/2"+"\r\n"+"Description 2", @issue.description}    
      should('set issues tracker') { assert_equal "Support", @issue.tracker.name}    
      should('set issues status') { assert_equal "Accepted", @issue.status.name}    
      should('set issues estimated_hours') { assert_equal 0, @issue.estimated_hours}    
      should('set issues author') { assert_equal 'admin@somenet.foo', @issue.author.mail }
      should("set issues 'Pivotal Story ID' field") { assert_equal @activity_hash['stories']['story']['id'], @issue.pivotal_story_id }
      should('set issues comments') { assert_equal 0, @issue.journals.size }
    end

    fast_context 'starting a story with 3 labels and 2 mappings' do
      setup do
        @activity_hash['stories']['story'] = { 'id' => 3,
                                               'url' => "http://www.pivotaltracker.com/services/v3/projects/102622/stories/4460116",
                                               'current_state' => 'started' } 
        @story = @activity_hash['stories']['story']
        Factory(:mapping, :project_id => 1, :tracker_project_id => @activity_hash['project_id'], :label => 'orange')
        Factory(:mapping, :project_id => 1, :tracker_project_id => @activity_hash['project_id'], :label => 'apple')
    
        @issue_count = Issue.count    
        Trackmine.read_activity @activity_hash
        @issues = Issue.all[-2..-1] # 2 last created issues
      end

      should('create 2 issues') { assert Issue.count - @issue_count == 2 }
      should 'create 2 issues with correct attributes values' do
        @issues.each do |issue|
          assert_equal "Story 3", issue.subject
          assert_equal "http://www.pivotaltracker.com/story/show/3"+"\r\n"+"Description 3", issue.description
          assert_equal "Feature", issue.tracker.name
          assert_equal "Accepted", issue.status.name    
          assert_equal 10, issue.estimated_hours    
          assert_equal 'admin@somenet.foo', issue.author.mail 
          assert_equal @activity_hash['stories']['story']['id'], issue.pivotal_story_id 
          assert_equal 0, issue.journals.size 
        end
      end
    end
      
    fast_context 'updating a story' do
      setup do
        @activity_hash['stories']['story'] = { 'id' => 1234,
                                               'url' => "http://www.pivotaltracker.com/services/v3/projects/102622/stories/1234",
                                               'description' => 'Foo description',
                                               'name' => 'foo name' } 
        @story = @activity_hash['stories']['story']
        @issues = []
        3.times do 
          issue = Factory.create(:issue)
          issue.pivotal_story_id = @story['id']  
          @issues << issue
        end
        Trackmine.read_activity @activity_hash
      end

      should 'change an issue description in each issue' do
        @issues.each{|issue| assert_equal @story['url'] +"\r\n"+ @story['description'], issue.reload.description}  
      end

      should 'change an issue subject in each issue' do
        @issues.each{|issue| assert_equal @story['name'], issue.reload.subject }
      end
    end

    fast_context 'restarting a story' do
      setup do
        @activity_hash['stories']['story'] = { 'id' => 1234,
                                               'url' => "http://www.pivotaltracker.com/services/v3/projects/102622/stories/1234",
                                               'current_state' => 'started' } 
        @story = @activity_hash['stories']['story']
        @issues = []
        status = IssueStatus.find_by_name 'Feedback' 
        3.times do 
          issue = Factory.create(:issue, :status_id => status.id)
          issue.pivotal_story_id = @story['id']  
          @issues << issue
        end
        Trackmine.read_activity @activity_hash
      end

      should 'change an issues status for "Accepted" in each issue' do
        @issues.each{|issue| assert_equal "Accepted", issue.reload.status.name}  
      end
    
      should 'assigned issue to user who restarted a story' do
        @issues.each{|issue| assert_equal "admin@somenet.foo", issue.reload.assigned_to.try(:mail)}  
      end
        
    end
  end
end


