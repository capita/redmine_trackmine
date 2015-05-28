require File.dirname(__FILE__) + '/../../spec_helper'

describe Trackmine do
  let(:activity_body) { JSON.parse(File.read(json_path(activity_name))) }
  let(:activity) { Trackmine::Activity.new(activity_body) }
  let(:read_activity) { Trackmine.read_activity(activity) }

  describe '.projects', vcr: { cassette_name: 'projects' } do
    before { Trackmine::Authentication.set_token('pbrudny@gmail.com') }
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

  context 'finish_story', vcr: { cassette_name: 'finish_story' } do
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

  describe 'updating story', vcr: { cassette_name: 'updating_story' } do
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
  end

  describe 'restarting a story', vcr: { cassette_name: 'restarting_story' }  do
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
end



