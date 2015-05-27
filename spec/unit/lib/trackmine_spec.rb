require File.dirname(__FILE__) + '/../../spec_helper'

describe Trackmine do
  let(:activity_body) { JSON.parse(File.read(json_path(activity_name))) }
  let(:activity) { Trackmine::Activity.new(activity_body) }
  let(:read_activity) { Trackmine.read_activity(activity) }

  describe '.projects' do
    before { Trackmine.set_token('pbrudny@gmail.com') }
    let(:projects) { Trackmine.projects }

    it 'returns an array of available projects' do
      expect(projects).to be_kind_of(Array)
    end

    it 'be a project instance' do
      expect(projects.first).to be_an_instance_of(PivotalTracker::Project)
    end
  end

  describe '.get_mapping' do
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



