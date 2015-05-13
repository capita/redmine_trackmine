require File.dirname(__FILE__) + '/../../spec_helper'


  describe Trackmine do
  # context '.projects method' do
  #   before { Trackmine.set_token('pbrudny@gmail.com') }
  #
  #   let(:projects) { Trackmine.projects }
  #
  #   it 'returns an array of available projects' do
  #     expect(projects).to be_kind_of(Array)
  #   end
  #
  #   it 'be a project instance' do
  #     expect(projects.first).to be_an_instance_of(PivotalTracker::Project)
  #   end
  # end
  #
  # context '.project_labels(tracker_project_id)' do
  #   let(:labels) { Trackmine.project_labels(1325832) }
  #
  #   it 'returns an array' do
  #     expect(labels).to be_kind_of(Array)
  #   end
  #
  #   it 'returns an array of project labels' do
  #     expect(%w(deployment admin epic).in?(labels))
  #   end
  # end
  #
  # context '.get_user_email(project_id, name)' do
  #   context 'with wrong attributes' do
  #     it 'raise an error' do
  #       expect { Trackmine.get_user_email(1325832, 'noname') }.to raise_error(Trackmine::WrongActivityData)
  #     end
  #   end
  #
  #   context 'with correct attributes' do
  #     it 'return authors email' do
  #       expect(Trackmine.get_user_email(1325832, 'Pedro')).to eq 'pbrudny@gmail.com'
  #     end
  #   end
  # end
  #
  # context '.get_mapping(tracker_project_id, label)' do
  #   context 'when no Redmine project mapped' do
  #     it 'does not raise an error' do
  #       expect(Trackmine.get_mapping(1325832, 'match')).not_to raise_exception
  #     end
  #   end
  #
  #   context 'when there is a mapping for the Redmine project' do
  #     let(:mapping) { FactoryGirl.create(:mapping, label: '') }
  #
  #     it('return a mapping object') do
  #       expect(Trackmine.get_mapping(mapping.tracker_project_id, '')).to eq mapping
  #     end
  #   end
  # end
  #
  # context '.get_story(activity)' do
  #   context 'having correct activity data' do
  #     let(:activity) { JSON.parse(File.read(json_path('story_started'))) }
  #
  #     it 'returns Story object' do
  #       expect(Trackmine.get_story(activity)).to be_kind_of(PivotalTracker::Story)
  #     end
  #   end

    # context 'having wrong activity data' do
    #   let(:activity) { { a:1 }.to_json }
    #
    #   it { expect { Trackmine.get_story(activity) }.to raise_error(Trackmine::WrongActivityData) }
    # end
  # end

  context '.create_issues method' do
    let(:email_address) { EmailAddress.new(address: 'pbrudny@gmail.com')}
    let!(:user) { create :user, email_address: email_address }

    let!(:issue_status) { create :issue_status, name: 'Accepted' }
    let(:activity) { JSON.parse(File.read(json_path('story_started'))) }

    let!(:project) { create :project }
    let!(:mapping_1) { create :mapping, tracker_project_id: '1327280', label: 'sank', project: project }
    let!(:mapping_2) { create :mapping, tracker_project_id: '1327280', label: 'snieg' }
    let!(:mapping_3) { create :mapping, tracker_project_id: '1327280', label: 'zima' }
    let!(:tracker) { create :tracker, name: 'Feature' }
    let(:issues) { Trackmine.create_issues(activity) }
    let(:issue) { issues.first }

    it 'create a proper Feature issue' do
      expect(issue).to be_an_instance_of Issue
      expect(issue.subject).to eq "Story 1"
      expect(issue.description).to eq ""
      expect(issue.tracker.name).to eq "Bug"
      expect(issue.status.name).eq "Accepted"
      expect(issue.estimated_hours).to eq 0
      expect(issue.author.mail).to eq 'admin@somenet.foo'
      expect(issue.author_id).to eq issue.assigned_to_id
      expect(issue.pivotal_project_id).to eq 1
      expect(issue.pivotal_story_id).to eq 2
      expect(issue.journals.size).to eq 5
    end
  end
  #
  # context '.update_issues(issues,tracker_project_id, params)' do
  #   context 'with no mapping' do
  #     before do
  #       @issue = FactoryGirl.create :issue
  #       @tpid = Mapping.all.collect{|t| t.tracker_project_id}.max + 1
  #     end
  #
  #     it('not raise an error') do
  #       expect_nothing_raised(Trackmine::MissingTrackmineMapping) { Trackmine.update_issues([@issue], @tpid, {})}
  #     end
  #   end
  #
  #   context 'with mapping' do
  #     before do
  #       @issue = FactoryGirl.create :issue
  #       FactoryGirl.create :mapping, :project_id => 1, :tracker_project_id => 888
  #     end
  #
  #     it 'update issues description' do
  #       Trackmine.update_issues( [@issue], 888, {:description => 'new d'} )
  #       expect 'new d', @issue.description
  #     end
  #
  #     it 'update issues subject' do
  #       Trackmine.update_issues( [@issue], 888, {:subject => 'new s'} )
  #       expect 'new s', @issue.subject
  #     end
  #   end
  # end
  #
  # context 'finish_story' do
  #   before do
  #     @story_id = 4460116
  #     @project_id = 102622
  #     @wrong_id = -1
  #   end
  #
  #   it("get response with a current_state 'finished'") do
  #     expect "finished", Trackmine.finish_story(@project_id, @story_id).current_state
  #   end
  #
  #   it("raise an errors when wrong story_id given") do
  #     expect_raise(Trackmine::PivotalTrackerError) { Trackmine.finish_story(@wrong_id, @wrong_id) }
  #   end
  # end
  #
  # context 'starting a story with one label' do
  #   before do
  #     @activity_hash['stories'] = [{ 'id' => 2,
  #                                    'url' => "http://www.pivotaltracker.com/services/v3/projects/102622/stories/4460116",
  #                                    'current_state' => 'started' }]
  #     @story = @activity_hash['stories'][0]
  #     FactoryGirl.create :mapping, :project_id => 1, :tracker_project_id => @activity_hash['project_id'], :label => 'education'
  #     @issue_count = Issue.count
  #     Trackmine.read_activity @activity_hash
  #     @issue = Issue.last
  #   end
  #
  #   it('create 1 issue') { expect Issue.count - @issue_count == 1 }
  #   it('set issues subject') { expect "Story 2", @issue.subject}
  #   it('set issues description') { expect "http://www.pivotaltracker.com/story/show/2"+"\r\n"+"Description 2", @issue.description}
  #   it('set issues tracker') { expect "Support", @issue.tracker.name}
  #   it('set issues status') { expect "Accepted", @issue.status.name}
  #   it('set issues estimated_hours') { expect 0, @issue.estimated_hours}
  #   it('set issues author') { expect 'admin@somenet.foo', @issue.author.mail }
  #   it("set issues 'Pivotal Story ID' field") { expect @activity_hash['stories'][0]['id'], @issue.pivotal_story_id }
  #   it('set issues comments') { expect 0, @issue.journals.size }
  # end
  #
  # context 'starting a story with 3 labels and 2 mappings' do
  #   before do
  #     @activity_hash['stories'] = [{ 'id' => 3,
  #                                    'url' => "http://www.pivotaltracker.com/services/v3/projects/102622/stories/4460116",
  #                                    'current_state' => 'started' }]
  #     @story = @activity_hash['stories'][0]
  #     FactoryGirl.create :mapping, :project_id => 1, :tracker_project_id => @activity_hash['project_id'], :label => 'orange'
  #     FactoryGirl.create :mapping, :project_id => 1, :tracker_project_id => @activity_hash['project_id'], :label => 'apple'
  #
  #     @issue_count = Issue.count
  #     Trackmine.read_activity @activity_hash
  #     @issues = Issue.all[-2..-1] # 2 last created issues
  #   end
  #
  #   it('create 2 issues') { expect Issue.count - @issue_count == 2 }
  #   it 'create 2 issues with correct attributes values' do
  #     @issues.each do |issue|
  #       expect "Story 3", issue.subject
  #       expect "http://www.pivotaltracker.com/story/show/3"+"\r\n"+"Description 3", issue.description
  #       expect "Feature", issue.tracker.name
  #       expect "Accepted", issue.status.name
  #       expect 10, issue.estimated_hours
  #       expect 'admin@somenet.foo', issue.author.mail
  #       expect @activity_hash['stories'][0]['id'], issue.pivotal_story_id
  #       expect 0, issue.journals.size
  #     end
  #   end
  # end
  #
  # context 'updating a release story with no owner' do
  #   before do
  #     @activity_hash['stories'] = [{ 'id' => 4,
  #                                    'url' => "http://www.pivotaltracker.com/services/v3/projects/102622/stories/4460116",
  #                                    'current_state' => 'unstarted' }]
  #     @story = @activity_hash['stories'][0]
  #     FactoryGirl.create :mapping, :project_id => 1, :tracker_project_id => @activity_hash['project_id'], :label => 'education2'
  #     @issue_count = Issue.count
  #     Trackmine.read_activity @activity_hash
  #     @issue = Issue.last
  #   end
  #
  #   it('create 0 issues') { expect Issue.count - @issue_count == 0}
  #
  # end
  #
  # context 'updating a story' do
  #   before do
  #     @activity_hash['stories'] = [{ 'id' => 4460116,
  #                                    'url' => "http://www.pivotaltracker.com/services/v3/projects/102622/stories/4460116",
  #                                    'description' => 'Foo description',
  #                                    'name' => 'foo name' }]
  #     @story = @activity_hash['stories'][0]
  #     @issues = []
  #     3.times do
  #       issue = FactoryGirl.create :issue
  #       issue.pivotal_story_id = @story['id']
  #       @issues << issue
  #     end
  #     Trackmine.read_activity @activity_hash
  #   end
  #
  #   it 'change an issue description in each issue' do
  #     @issues.each{ |issue| expect "http://www.pivotaltracker.com/story/show/#{@story['id']}" +"\r\n"+ @story['description'], issue.reload.description}
  #   end
  #
  #   it 'change an issue subject in each issue' do
  #     @issues.each{ |issue| expect @story['name'], issue.reload.subject }
  #   end
  # end
  #
  # context 'restarting a story' do
  #   before do
  #     @activity_hash['stories'] = [{ 'id' => 4460116,
  #                                    'url' => "http://www.pivotaltracker.com/services/v3/projects/102622/stories/4460116",
  #                                    'current_state' => 'started' }]
  #     @story = @activity_hash['stories'][0]
  #     @issues = []
  #     status = IssueStatus.find_by_name 'Feedback'
  #     3.times do
  #       issue = FactoryGirl.create :issue, :status_id => status.id
  #       issue.pivotal_story_id = @story['id']
  #       @issues << issue
  #     end
  #     Trackmine.read_activity @activity_hash
  #   end
  #
  #   it 'change an issues status for "Accepted" in each issue' do
  #     @issues.each{ |issue| expect "Accepted", issue.reload.status.name }
  #   end
  #
  #   it 'assigned issue to user who restarted a story' do
  #     @issues.each{ |issue| expect "admin@somenet.foo", issue.reload.assigned_to.try(:mail) }
  #   end
  # end
end


