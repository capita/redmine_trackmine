module Trackmine
  class IssuesRestarter

    def initialize(issues, activity)
      self.issues = issues
      self.activity = activity
    end

    def run
      issues_updater.update_issues(params)
    end

    def issues_updater
      Trackmine::IssuesUpdater.new(issues, activity)
    end

    private

    attr_accessor :issues, :activity

    def author
      activity.author
    end

    def status
      IssueStatus.find_by_name(ACCEPTED_STATUS)
    end

    def params
      {status: status, assigned_to: author}
    end
  end
end