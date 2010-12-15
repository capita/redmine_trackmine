require File.dirname(__FILE__) + '/../test_helper'

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

#    context 'Issue instance' do
#      context 'with no Pivotal Story ID custom field' do
#        subject { @issue = Factory.create(:issue) }
#        should 'have pivotal_custom_value method' do
#          assert @issue.respond_to? :pivotal_custom_value
#        end

#        should 'have pivotal_story_id  method' do
#          assert @issue.respond_to? :pivotal_story_id
#        end
#      end

#      should 'have pivotal_story_id= method' do
#        assert Issue.respond_to? :find_by_story_id
#      end
#    end
  end
end
