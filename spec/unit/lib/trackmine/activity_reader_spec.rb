require File.dirname(__FILE__) + '/../../../spec_helper'

describe Trackmine::ActivityReader, vcr: { cassette_name: 'activity_reader' }  do
  let(:reader) { Trackmine::ActivityReader.new(activity) }

  context 'story started' do
    context 'no issues yet' do
      let(:activity) { double :activity, :'story_edited?'=> false, story_id: 1, :'story_started?'=> true }
      it 'runs Trackmine::IssuesCreator' do
        expect_any_instance_of(Trackmine::IssuesCreator).to receive(:run)
        reader.run
      end
    end

    context 'issues exist' do
      let(:activity) { double :activity, :'story_edited?'=> false, story_id: 92844256, :'story_started?'=> true }
      it 'runs Trackmine::IssuesRestarter' do
        expect_any_instance_of(Trackmine::IssuesRestarter).to receive(:run)
        reader.run
      end
    end
  end

  context 'story edited' do
    let(:activity) { double :activity, :'story_edited?'=> true, story_id: 92844256, :'story_started?'=> false }
    it 'runs Trackmine::IssuesUpdater' do
      expect_any_instance_of(Trackmine::IssuesUpdater).to receive(:run)
      reader.run
    end
  end
end
