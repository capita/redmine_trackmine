require File.dirname(__FILE__) + '/../../../spec_helper'

describe Trackmine::StoryFinisher do
  let(:story) { double :story, story_type: story_type }
  let(:finisher) { Trackmine::StoryFinisher.new(story) }

  context 'when feature' do
    let(:story_type) { 'feature' }
    it 'changes story state to finished' do
      expect(story).to receive(:update).with(current_state: 'finished')
      finisher.run
    end
  end

  context 'when bug' do
    let(:story_type) { 'bug' }
    it 'changes story state to finished' do
      expect(story).to receive(:update).with(current_state: 'finished')
      finisher.run
    end
  end

  context 'when chore' do
    let(:story_type) { 'chore' }
    it 'changes story state to accepted' do
      expect(story).to receive(:update).with(current_state: 'accepted')
      finisher.run
    end
  end
end