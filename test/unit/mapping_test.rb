require File.dirname(__FILE__) + '/../test_helper'

class MappingTest < ActiveSupport::TestCase
  # Loading Redmine fixtures
  fixtures :projects, :versions, :users, :roles, :members, :member_roles, :issues, :journals, :journal_details,
           :trackers, :projects_trackers, :issue_statuses, :enabled_modules, :enumerations, :boards, :messages,
           :attachments, :custom_fields, :custom_values, :time_entries

  context 'A Mapping instance' do
    subject { Factory(:mapping) }
    should_belong_to :project
    should_validate_presence_of :project_id
    should_validate_presence_of :tracker_project_id
    should_validate_uniqueness_of :tracker_project_id, :scoped_to => :label
    should_have_db_columns :estimations, :story_types
    should_validate_presence_of :estimations, :story_types

    should 'be created when attributes are valid' do
      mapping = Factory.build(:mapping)
      assert mapping.save
    end 

    should 'be able to store hash in estimations attribute' do
      mapping = Factory.build(:mapping)
      assert mapping.estimations.kind_of? Hash
      assert_equal 1, mapping.estimations[1]
    end 

    should 'be able to store hash in story_types attribute' do
      mapping = Factory.build(:mapping)
      assert mapping.story_types.kind_of? Hash
      assert_equal "Feature", mapping.story_types['feature'] 
    end 

  end
end

