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
     
      if activity['stories']['story']['current_state'] == "started"
      end
      #if activity['stories']['story']['name']
      #if activity['stories']['story']['description']
      
#      case activity['event_type']
#        when "story_update"
#          ""# no matter if its start or restart- the same behaviour
#          labels = activity['stories']['story']['labels'].to_s.split(',')
#          create_issue(activity) if labels.blank?         
#          labels.each{|label| create_issue(activity,label)}
#        else
#          raise WrongActivityData.new("Not supported event type.")
#      end
    end

    # Finds author of the tracker activity and returns its email
    def get_user_email(project_id, name)
      begin
        set_token('super_user') if @token.nil?
        project = PivotalTracker::Project.find project_id.to_i
        project.memberships.all.select{|m| m.name == name }[0].email
      rescue => e
        raise WrongActivityData.new("Can't get email of the Tracker user: #{name} in project id: #{project_id}. " + e)
      end 
    end
    
    # Return PivotalTracker story for given activity    
    def get_story(activity)
      project_id = activity['project_id']
      story_id = activity['stories']['story']['id']
      story = PivotalTracker::Project.find(project_id).stories.find(story_id)
      rescue => e
      raise WrongActivityData.new("Can't get story: #{story_id} from Pivotal Tracker. " + e)
      return story 
    end

    # Return object which maps Redmine project with Tracker project
    def get_mapping(tracker_project_id, label)
      mapping = Mapping.find :first, :conditions=>['tracker_project_id=? AND label=? ', tracker_project_id, label.to_s]
      raise MissingTrackmineMapping.new("Can't find mapping for project:#{tracker_project_id} and label:#{label}")  if mapping.nil?
      # TODO: email with error!
      return mapping
    end    

    # Creates a Redmine issues-
    def create_issues(activity)
      story = get_story(activity)
      raise WrongActivityData.new("Can't get story from #{activity['stories']['story']['id']}") if story.nil?

      # getting story owners email
      email = get_user_email( story.project_id, story.owned_by )
      author = User.find_by_mail email

      # Setting issue attributes
      description = story.url + "\r\n" + story.description
      status = IssueStatus.find_by_name "Accepted"
      raise WrongTrackmineConfiguration.new("Can't find Redmine IssueStatus: 'Accepted' ") if status.nil?  
      issues = []
      labels = story.labels.to_s.split(',')
      labels = [''] if labels.blank?
      labels.each do |label|
        mapping = get_mapping(activity['project_id'], label)
        raise WrongActivityData.new("Can't find project") if mapping.project.nil?
        tracker = Tracker.find_by_name mapping.story_types[story.story_type] 
        raise WrongTrackmineConfiguration.new("Can't find Redmine suitable Tracker") if tracker.nil?  
        estimated_hours = mapping.estimations[story.estimate.to_i.to_s].to_i 
       
        # Creating a new Redmine issue
        issue = mapping.project.issues.create(:subject => story.name,
                                              :description => description,
                                              :author_id => author.id,
                                              :tracker_id => tracker.id, 
                                              :status_id => status.id,
                                              :estimated_hours => estimated_hours)

        # Setting value of 'Pivotal Story ID' issue custom field
        custom_field = issue.custom_field_values.select{|cv| cv.custom_field.name == "Pivotal Story ID"}.first
        raise WrongTrackmineConfiguration.new("Can't find 'Pivotal Story ID' custom field for issues") if custom_field.nil?
        custom_field.update_attributes :value => story.id

        #adding comments (journals)
        story.notes.all.each do |note|
          user = User.find_by_mail get_user_email(story.project_id, note.author) 
          journal = issue.journals.new :notes => note.text
          journal.user_id = user.id unless user.nil?
          journal.save
        end

        issues << issue
      end 
      return issues
    end
    
    # Updates Redmine issues- title, description only
    def update_issues(activity)
      
    end

    # Updates Redmine issues- status and owner when story restarted
    def story_restart
      
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

