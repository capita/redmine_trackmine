require File.expand_path('../../spec_helper', __FILE__)

describe Mapping do
  let(:mapping) { create :mapping }

  it { should belong_to(:project) }

  describe 'validations' do
    it { should validate_presence_of(:project_id) }
    it { should validate_presence_of(:tracker_project_id) }
    it { should validate_uniqueness_of(:tracker_project_id).scoped_to(:label) }
    it { should validate_presence_of(:estimations) }
    it { should validate_presence_of(:story_types) }
  end

  it 'stores hash in estimations attribute' do
    expect(mapping.estimations['2']).to eql '4'
  end

  it 'stores hash in story_types attribute' do
    expect(mapping.story_types['feature']).to eql 'Feature'
  end
end

