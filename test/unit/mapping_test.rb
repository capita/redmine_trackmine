require File.dirname(__FILE__) + '/../test_helper'

class MappingTest < ActiveSupport::TestCase
  fixtures :projects, :versions, :users, :roles, :members, :member_roles, :issues, :journals, :journal_details,
           :trackers, :projects_trackers, :issue_statuses, :enabled_modules, :enumerations, :boards, :messages,
           :attachments, :custom_fields, :custom_values, :time_entries

  context 'A Mapping instance' do

    should_belong_to :project
    should_validate_presence_of :project_id
    should_validate_presence_of :tracker_project_id
    should_validate_uniqueness_of :tracker_project_id, :scoped_to => :label

#    should 'be created when attributes are valid' do
#      mapping = Factory.build(:mapping)
#      assert mapping.save
#    end 

  end
end

