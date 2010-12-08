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
          "" #create_issue(activity)
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
    
    # Return object which maps Redmine project with Tracker project
    def get_mapping(tracker_project_id, label)
      mapping = Mapping.find :first, :conditions=>['tracker_project_id=? AND label=? ', tracker_project_id, label.to_s]
      raise MissingTrackmineMapping.new("Can't find mapping for project:#{tracker_project_id} and label:#{label}")  if mapping.nil?
      return mapping
    end    

    # Creates a Redmine issue
    def create_issue(activity)
      author = User.find_by_mail(get_authors_email(activity))
      raise WrongActivityData.new("Can't find the author") if author.nil?
      mapping = get_mapping(activity['project_id'], activity['labels'])
      raise WrongActivityData.new("Can't find project") if mapping.project.nil?
      issue_subject = activity['stories']['story']['name']
      description = activity['stories']['story']['url'] + "\r\n" + activity['description']
      status = IssueStatus.find_by_name "Accepted"
      raise WrongTrackmineConfiguration.new("Can't find Redmine IssueStatus: 'Accepted' ") if status.nil?  
      tracker = Tracker.find_by_name mapping.story_types[activity['stories']['story']['story_type']] #bug->bug, feature->feature, chore->support
      raise WrongTrackmineConfiguration.new("Can't find Redmine suitable Tracker") if tracker.nil?  
      estimated_hours = mapping.estimations[activity['stories']['story']['estimate_type']] # 1->1h, 2->4h, 3->10h, nil for bug and chore

      # Creates new Redmine issue
      issue = mapping.project.issues.create(:subject=> issue_subject,
                            :description => description,
                            :author_id => author.id,
                            :tracker_id=> tracker.id, 
                            :status_id => status.id,
                            :estimated_hours=> estimated_hours)

      # Sets value of 'Pivotal Tracker ID' issue custom field
      custom_field = issue.custom_field_values.select{|cv| cv.custom_field.name=="Pivotal Tracker ID"}.first
      raise WrongTrackmineConfiguration.new("Can't find 'Pivotal Tracker ID' custom field for issues") if custom_field.nil?
      custom_field.update_attributes :value => activity['stories']['story']['id']
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
  class MissingTrackmineMapping < StandardError; end;
  
  # Error to be raised when fails due to Trackmine configuration
  class WrongTrackmineConfiguration < StandardError; end;

end

