module Trackmine
  class ActivityReader

    def initialize(activity)
      self.activity = activity
    end

    def run
      if issues.empty? && activity.story_started?
        create_issues(activity)
      elsif issues.present? && activity.story_started?
        story_restart(issues, activity)
      elsif issues.present? && activity.story_edited?
        issues_updater(issues, activity)
      end
    end

    def issues
      @issues ||= Issue.find_by_story_id(activity.story_id)
    end

    def create_issues(activity)
      Trackmine::IssuesCreator.new(activity).run
    end

    def issues_updater(issues, activity)
      Trackmine::IssuesUpdater.new(issues, activity).run
    end

    # Finds author of the tracker activity and returns its email
    def get_user_email(project_id, name)
      Trackmine::PivotalProject.new(project_id).participant_email(name)
    end

    def get_mapping(tracker_project_id, label)
      Mapping.where(['tracker_project_id=? AND label=? ', tracker_project_id, label.to_s]).first
    end

    # Updates Redmine issues- status and owner when story restarted
    def story_restart(issues, activity)
      issues_updater = Trackmine::IssuesUpdater.new(issues, activity)

      status = IssueStatus.find_by_name(ACCEPTED_STATUS)
      params = {status: status, assigned_to: activity.author}
      issues_updater.update_issues(params)
    end

    # Finishes the story when the Redmine issue is closed
    def finish_story(project_id, story_id)
      begin
        set_super_token
        story = PivotalTracker::Story.find(story_id, project_id)
        case story.story_type
          when 'feature'
            story.update(current_state: 'finished')
          when 'bug'
            story.update(current_state: 'finished')
          when 'chore'
            story.update(current_state: 'accepted')
        end
      rescue => e
        raise PivotalTrackerError, "Can't finish the story id:#{story_id}. #{e}"
      end
    end

    private

    attr_accessor :activity
  end
end

