require File.dirname(__FILE__) + '/../../../spec_helper'

describe Trackmine::IssuesCreator, vcr: { cassette_name: 'issues_creator' }  do
  let(:activity_body) { JSON.parse(File.read(json_path(activity_name))) }
  let(:activity) { Trackmine::Activity.new(activity_body) }
  let(:creator) { Trackmine::IssuesCreator.new(activity) }

  describe '#run' do
    let(:activity_name) { 'story_started' }
    let(:project) { Project.find(1) }

    it 'create issues' do
      expect{ creator.run }.to change { Issue.count }.by(3)
    end
  end
end
