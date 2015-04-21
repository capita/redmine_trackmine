require File.dirname(__FILE__) + '/../spec_helper'

class TrackmineTest < Test::Unit::TestCase

  context 'After loading init.rb' do
     context 'Project instance' do
       subject { Project.first }
       should_have_many :mappings
    end

    context 'Issue class' do
      should 'have find_by_story_id method' do
        assert Issue.respond_to? :find_by_story_id
      end
    end
  end
end
