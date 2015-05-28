module Trackmine
  ACCEPTED_STATUS = 'Accepted'

  WrongActivityData = Class.new(StandardError)
  MissingTrackmineConfig = Class.new(StandardError)
  MissingCredentials = Class.new(StandardError)
  WrongCredentials = Class.new(StandardError)
  MissingTrackmineMapping = Class.new(StandardError)
  WrongTrackmineConfiguration = Class.new(StandardError)
  PivotalTrackerError = Class.new(StandardError)

  class << self
    attr_writer :error_notification

    def set_error_notification
      @error_notification = Trackmine::Configuration.new.error_notification
    end

    def error_notification
      @error_notification
    end

    def projects
      PivotalTracker::Project.all
    end

    def set_token(email)
      Trackmine::Authentication.set_token(email)
    end

    def project_labels(tracker_project_id)
      Trackmine::PivotalProject.new(tracker_project_id).labels
    end

    def read_activity(activity)
      Trackmine::ActivityReader.new(activity).run
    end

    def create_issues(activity)
      Trackmine::IssuesCreator.new(activity).run
    end

    def get_user_email(project_id, name)
      Trackmine::PivotalProject.new(project_id).participant_email(name)
    end

    def get_mapping(tracker_project_id, label)
      Mapping.where(['tracker_project_id=? AND label=? ', tracker_project_id, label.to_s]).first
    end

    def finish_story(project_id, story_id)
      story = Trackmine::PivotalProject.new(project_id).story(story_id)
      Trackmine::StoryFinisher.new(story).run
    end
  end
end

