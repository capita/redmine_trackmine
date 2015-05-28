require File.dirname(__FILE__) + '/../spec_helper'

describe 'ProjectPatch' do
  context 'After loading init.rb' do
    context 'Project' do
      subject { Project.first }
      it { should have_many(:mappings) }
    end
  end
end
