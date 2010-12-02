require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
#require 'spec_helper'

describe Mapping, "creation / validation" do

  it 'should create mapping with valid attributes' do
    lambda { Factory.create(:mapping) }.
      should_not raise_error ActiveRecord::RecordInvalid
  end

  it "should have some validations" do
    should validate_presence_of(:project_id)
    should validate_presence_of(:tracker_project_id)
  end
end
