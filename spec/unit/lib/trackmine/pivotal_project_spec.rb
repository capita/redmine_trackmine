require File.dirname(__FILE__) + '/../../../spec_helper'

describe Trackmine::PivotalProject, vcr: { cassette_name: 'pivotal_project' } do
  let(:pivotal_project) { Trackmine::PivotalProject.new(1325832) }

  describe '#labels' do
    let(:labels) { pivotal_project.labels }

    it 'returns an array' do
      expect(labels).to be_kind_of(Array)
    end

    it 'returns an array of project labels' do
      expect(%w(deployment admin epic).in?(labels))
    end
  end

  describe '#participant_email', vcr: { cassette_name: 'participant_email' } do
    context 'with wrong attributes' do
      it 'raises error' do
        expect { pivotal_project.participant_email('noname') }
            .to raise_error(Trackmine::PivotalTrackerError)
      end
    end

    context 'with correct attributes' do
      it 'returns authors email' do
        expect(pivotal_project.participant_email('Pedro')).to eq 'pbrudny@gmail.com'
      end
    end
  end
end

