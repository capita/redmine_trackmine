module Trackmine
  ACCEPTED_STATUS = 'Accepted'
  class << self
    attr_writer :error_notification

    # Gets data from config/trackmine.yml
    def get_credentials
      trackmine_path = File.join(Rails.root, 'config', 'trackmine.yml')
      raise MissingTrackmineConfig.new("Missing trackmine.yml configuration file in /config") unless File.exist?(trackmine_path)
      YAML.load_file(trackmine_path)
    end

    # Sets email for error notification
    def set_error_notification
      @error_notification = get_credentials['error_notification']
    end

    # Gets email for error notification
    def error_notification
      @error_notification
    end

    # Returns all projects for the current user
    def projects
      PivotalTracker::Project.all
    end

    # Sets PivotalTracker token using user credentials from config/trackmine.yml
    def set_token(email)
      credential = get_credentials[email]
      raise MissingCredentials.new("Missing credentials for #{email} in trackmine.yml") if credential.nil?
      begin
        if (credential['token'])
          @token = credential['token']
          PivotalTracker::Client.token = @token
        else
          @token = PivotalTracker::Client.token(credential['email'], credential['password'])
        end
        PivotalTracker::Client.use_ssl = true # to access pivotal projects which use https
      rescue => e
        raise WrongCredentials.new("Wrong Pivotal Tracker credentials in trackmine.yml. #{e}")
      end
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
      issues_updater.update_issues({ status: status, assigned_to: activity.author })
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

    def set_super_token
      set_token('super_user') if @token.nil?
    end
  end

  class WrongActivityData < StandardError; end;
  class MissingTrackmineConfig < StandardError; end;
  class MissingCredentials < StandardError; end;
  class WrongCredentials < StandardError; end;
  class MissingTrackmineMapping < StandardError; end;
  class WrongTrackmineConfiguration < StandardError; end;
  class PivotalTrackerError < StandardError; end;

end

