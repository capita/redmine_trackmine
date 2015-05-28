require File.dirname(__FILE__) + '/../../../spec_helper'

describe Trackmine::Activity, vcr: { cassette_name: 'trackmine_activity' }  do
  let(:activity_body) { JSON.parse(File.read(json_path(activity_name))) }
  let(:activity) { Trackmine::Activity.new(activity_body) }
  let(:creator) { Trackmine::IssuesCreator.new(activity) }

  describe '#story' do
    context 'correct activity data' do
      let(:activity_name) { 'story_started' }

      it 'returns Story object' do
        expect(activity.story).to be_kind_of(PivotalTracker::Story)
      end
    end

    context 'wrong activity data' do
      let(:activity_body) { { a:1 }.to_json }
      it { expect { activity.story }.to raise_error(Trackmine::PivotalTrackerError) }
    end
  end
end
