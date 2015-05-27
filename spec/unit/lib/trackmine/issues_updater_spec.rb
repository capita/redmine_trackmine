require File.dirname(__FILE__) + '/../../../spec_helper'

describe Trackmine::IssuesUpdater do
  let(:project) { Project.find 1 }
  let(:issue) { Issue.find 1 }
  let(:activity) { double :activity, project_id: 888 }
  let(:issues_updater) { Trackmine::IssuesUpdater.new([issue], activity) }

  describe '#run' do
    context 'with mapping' do
      let!(:mapping) { create :mapping, project: project, tracker_project_id: 888 }

      context 'description changed' do
        let(:params) { { description: 'new description' } }

        it 'update issues description' do
          issues_updater.update_issues(params)
          expect(issue.description).to eq 'new description'
        end
      end

      context 'subject changed' do
        let(:params) { { subject: 'new subject' } }

        it 'update issues subject' do
          issues_updater.update_issues(params)
          expect(issue.subject).to eq 'new subject'
        end
      end
    end
  end
end
