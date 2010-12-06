module Trackmine

  class << self

    # Returns all projects for the current user
    def projects
      PivotalTracker::Project.all
    end

    # Gets credentials for user identified by its email and sets PivotalTracker token.
    def set_token(email)
      trackmine_path = File.join(Rails.root, 'config', 'trackmine.yml')
      raise MissingTrackmineConfig.new("Missing trackmine.yml configuration file in /config") unless File.exist?(trackmine_path)
      credentials = YAML.load_file(trackmine_path)
      credential = credentials[email] 
      raise MissingCredentials.new("Missing credentials for #{email} in trackmine.yml") if credential.nil? 
      begin
        @token = PivotalTracker::Client.token(credential['email'], credential['password'])
      rescue => e
        raise WrongCredentials.new("Wrong Pivotal Tracker credentials in trackmine.yml. #{e}")
      end
    end 
      
    # Returns all labels from specified Pivotal Tracker project   
    def project_labels(tracker_project_id)
      tracker_project = PivotalTracker::Project.find tracker_project_id
      tracker_project.stories.all.collect{|s| s.labels }.join(',').squeeze.split(',').uniq
    end
    
    def read_activity(activity)
      case activity['event_type']
        when "story_create"
          ""
        when "story_update"
          ""
        else
          raise WrongActivityData.new("Not supported event type.")
      end
    end

    # Finds author of the tracker activity and returns its email
    def get_authors_email(activity)
      begin
        set_token('super_user') if @token.nil?
        project = PivotalTracker::Project.find activity['project_id'].to_i
        project.memberships.all.select{|m| m.name == activity['author']}[0].email
      rescue => e
        raise WrongActivityData.new("Can't get email of the Tracker activity author."+e)
      end 
    end
    
    def get_mapping
      
    end    
  end
  
  # Error to be raised when any problem occured while parsing activity data
  class WrongActivityData < StandardError; end;

  # Error to be raised when trackmine.yml can't be found in /config
  class MissingTrackmineConfig < StandardError; end;
  
  # Error to be raised when missing credentials for given email
  class MissingCredentials < StandardError; end;
    
  # Error to be raised when wrong credentials given
  class WrongCredentials < StandardError; end;

  # Error to be raised when missing Trackmine mapping. 
  #Tracker project/label with Redmine (sub)project
  class MissingTrackmineMapping < StandardError; end;
  

end

