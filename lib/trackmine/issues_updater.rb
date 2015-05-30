module Trackmine
  class IssuesUpdater

    def initialize(issues, activity)
      self.issues = issues
      self.activity = activity
    end

    def run
      story_update
    end

    def story_update
      update_issues(params_changed)
    end

    def params_changed
      if new_value['description'].present?
        { description: "#{story_url}\r\n#{new_value['description']}" }
      elsif new_value['name'].present?
        { subject: new_value['name'] }
      end
    end

    def update_issues(params)
      issues.each { |issue| issue.update_attributes!(params) if mapping_still_exists?(issue) }
    end

    def mapping_still_exists?(issue)
      issue.project.mappings.where(tracker_project_id: pivotal_project_id).present?
    end

    private

    attr_accessor :issues, :activity

    def story_url
      activity.story.url
    end

    def new_value
      activity.new_value
    end

    def pivotal_project_id
      activity.project_id
    end
  end
end