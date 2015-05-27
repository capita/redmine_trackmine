module Trackmine
  class ActivityReader

    def initialize(activity)
      self.activity = activity
    end

    def run
      if issues.present?
        update_issues
      elsif activity.story_started?
        Trackmine::IssuesCreator.new(activity).run
      end
    end

    def update_issues
      if activity.story_started?
        Trackmine::IssuesRestarter.new(issues, activity).run
      elsif activity.story_edited?
        Trackmine::IssuesUpdater.new(issues, activity).run
      end
    end

    def issues
      @issues ||= Issue.find_by_story_id(activity.story_id)
    end

    private

    attr_accessor :activity
  end
end

