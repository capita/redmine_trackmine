require File.dirname(__FILE__) + '/../spec_helper'

describe 'IssuePatch' do
  context 'After loading init.rb' do
    context 'Issue' do
      it 'has find_by_story_id method' do
        expect(Issue.respond_to? :find_by_story_id)
      end
    end
  end
end
