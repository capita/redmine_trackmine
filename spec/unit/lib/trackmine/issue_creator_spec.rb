require File.dirname(__FILE__) + '/../../../spec_helper'

describe Trackmine::IssueCreator do
  let(:label) { 'zima' }
  let(:author) { User.find(2) }
  let(:project_id) { '1327280' }
  let(:story) { Trackmine::PivotalProject.new(project_id).story(94184406) }
  let(:issue_attributes) do
    {
      project_id: '1327280',
      story: story,
      author: author
    }
  end
  let(:creator) { Trackmine::IssueCreator.new(label, issue_attributes) }

  describe '#run' do
    let(:issue) { Issue.find_by_story_id(94184406).last }
    it 'creates custom values' do
      expect{ creator.run }.to change { CustomValue.count }.by(4)
    end

    it 'runs CustomValueCreator' do
      expect_any_instance_of(Trackmine::CustomValuesCreator).to receive(:run)
      creator.run
    end

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
end