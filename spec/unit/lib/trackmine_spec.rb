require File.dirname(__FILE__) + '/../../spec_helper'

describe Trackmine do
  let(:activity_body) { JSON.parse(File.read(json_path(activity_name))) }
  let(:activity) { Trackmine::Activity.new(activity_body) }
  let(:read_activity) { Trackmine.read_activity(activity) }

  context '.projects method' do
    before { Trackmine.set_token('pbrudny@gmail.com') }

    let(:projects) { Trackmine.projects }

    it 'returns an array of available projects' do
      expect(projects).to be_kind_of(Array)
    end

    it 'be a project instance' do
      expect(projects.first).to be_an_instance_of(PivotalTracker::Project)
    end
  end

  context '.project_labels(tracker_project_id)' do
    let(:labels) { Trackmine.project_labels(1325832) }

    it 'returns an array' do
      expect(labels).to be_kind_of(Array)
    end

    it 'returns an array of project labels' do
      expect(%w(deployment admin epic).in?(labels))
    end
  end

  context '.get_user_email(project_id, name)' do
    context 'with wrong attributes' do
      it 'raise an error' do
        expect { Trackmine.get_user_email(1325832, 'noname') }.to raise_error(Trackmine::PivotalTrackerError)
      end
    end

    context 'with correct attributes' do
      it 'return authors email' do
        expect(Trackmine.get_user_email(1325832, 'Pedro')).to eq 'pbrudny@gmail.com'
      end
    end
  end

  context '.get_mapping(tracker_project_id, label)' do
    context 'when no Redmine project mapped' do
      it 'does not raise an error' do
        expect(Trackmine.get_mapping(1325832, 'match')).not_to raise_exception
      end
    end

    context 'when there is a mapping for the Redmine project' do
      let(:mapping) { create(:mapping, label: '') }

      it('return a mapping object') do
        expect(Trackmine.get_mapping(mapping.tracker_project_id, '')).to eq mapping
      end
    end
  end

  context '.get_story(activity)' do
    context 'having correct activity data' do
      let(:activity_name) { 'story_started' }

      it 'returns Story object' do
        expect(Trackmine::Activity.new(activity_body).story).to be_kind_of(PivotalTracker::Story)
      end
    end

    context 'having wrong activity data' do
      let(:activity_body) { { a:1 }.to_json }

      it { expect { Trackmine::Activity.new(activity_body).story }.to raise_error(Trackmine::PivotalTrackerError) }
    end
  end

  context '.create_issues method' do
    let(:activity_name) { 'story_started' }
    let(:project) { Project.find(1) }
    let(:issues) { Trackmine.create_issues(activity) }
    let(:issue) { issues.first }

    it 'create a proper Feature issue' do
      expect(issue).to be_an_instance_of Issue
      expect(issue.subject).to eq 'jazda na sankach w trojkach'
      expect(issue.description).to eq "https://www.pivotaltracker.com/story/show/94184406\r\njazda z gorki w dol po sniegu w parach czyli w trzy osoby\r\n"
      expect(issue.tracker.name).to eq 'Feature'
      expect(issue.status.name).to eq 'Accepted'
      expect(issue.estimated_hours).to eq 1.0
      expect(issue.author.mail).to eq 'pbrudny@gmail.com'
      expect(issue.author_id).to eq issue.assigned_to_id
      expect(issue.pivotal_project_id).to eq 1327280
      expect(issue.pivotal_story_id).to eq 94184406
      expect(issue.journals.size).to eq 0
    end
  end

  context '.update_issues(issues,tracker_project_id, params)' do
    let(:project) { Project.find 1 }
    let(:issue) { Issue.find 1 }
    let(:activity) { double :activity, project_id: 888 }
    let(:issues_updater) { Trackmine::IssuesUpdater.new([issue], activity) }

    context 'with mapping' do
      let!(:mapping) { create :mapping, project: project, tracker_project_id: 888 }

      context 'description changed' do
        let(:params) { { description: 'new description' } }

        it 'update issues description' do
          issues_updater.update_issues(params)
          expect(issue.description).to eq 'new description'
        end
      end

      context 'subject changed' do
        let(:params) { { subject: 'new subject' } }

        it 'update issues subject' do
          issues_updater.update_issues(params)
          expect(issue.subject).to eq 'new subject'
        end
      end
    end
  end

  context 'finish_story' do
    let(:story_id) { 94184406 }
    let(:project_id) { 1327280 }
    let(:wrong_id) { -1 }
    let(:story) { PivotalTracker::Story.find(story_id, project_id) }

    it("get response with a current_state 'finished'") do
      expect_any_instance_of(PivotalTracker::Story).to receive(:update).with({current_state: 'finished'})
      Trackmine.finish_story(project_id, story_id)
    end

    it('raise an errors when wrong story_id given') do
      expect {Trackmine.finish_story(wrong_id, wrong_id)}.to raise_error(Trackmine::PivotalTrackerError)
    end
  end


  describe 'updating story' do
    let(:issues) { Issue.find([2])}

    context 'description' do
      let(:activity_name) { 'story_description_update' }
      let(:new_description) do
        "https://www.pivotaltracker.com/story/show/94184406" +"\r\n"+ "jazda z gorki w dol po sniegu w parach czyli we dwoje\r\n"
      end

      it 'change an issue description in each issue' do
        read_activity

        issues.each do |issue|
          expect(issue.reload.description).to eq new_description
        end
      end
    end

    # TODO: fix it. Does load CustomValues when test description context
    # context 'subject' do
    #   let(:activity_name) { 'story_subject_update' }
    #
    #   it 'change an issue subject in each issue' do
    #     read_activity
    #
    #     issues.each do |issue|
    #       expect(issue.reload.subject).to eq "jazda na sankach w parach"
    #     end
    #   end
    # end
  end

  describe 'restarting a story' do
    let(:activity_name) { 'story_restarted' }

    context 'there is an associated Redmine issue' do
      let(:issues) { Issue.find([3])}

      it 'change an issues status for "Accepted" in each issue' do
        read_activity
        issues.each do |issue|
          expect(issue.reload.status.name).to eq 'Accepted'
        end
      end

      it 'assigned issue to user who restarted a story' do
        issues.each do |issue|
          expect(issue.reload.assigned_to.try(:mail)).to eq 'pbrudny@gmail.com'
        end
      end
    end
  end

  # TODO: for later
  # context 'starting a story with one label' do
  #   before do
  #     @activity_hash['stories'] = [{ 'id' => 2,
  #                                    'url' => "http://www.pivotaltracker.com/services/v3/projects/102622/stories/4460116",
  #                                    'current_state' => 'started' }]
  #     @story = @activity_hash['stories'][0]
  #     FactoryGirl.create :mapping, :project_id => 1, :tracker_project_id => @activity_hash['project_id'], :label => 'education'
  #     @issue_count = Issue.count
  #     Trackmine.read_activity @activity_hash
  #   end
  #
  #   let(:issue) { Issue.last }
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

end



