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
        PivotalTracker::Client.use_ssl = true # to access pivotal projects which use https
      rescue => e
        raise WrongCredentials.new("Wrong Pivotal Tracker credentials in trackmine.yml. #{e}")
      end
    end 
      
    # Returns all labels from specified Pivotal Tracker project   
    def project_labels(tracker_project_id)
      tracker_project = PivotalTracker::Project.find tracker_project_id
      tracker_project.stories.all.collect{|s| s.labels }.join(',').squeeze.split(',').uniq
    end
        
    # Main method parsing PivotalTracker activity
    def read_activity(activity)
      story = activity['stories']['story']
      issues = Issue.find_by_story_id story['id'].to_s
      if issues.empty?
        create_issues(activity)
      else 
        story_restart(issues, activity) if story['current_state'] == "started"
        update_issues(issues, activity['project_id'], { :description => story['url'] +"\r\n"+ story['description'] }) if story['description'] 
        update_issues(issues, activity['project_id'] ,{ :subject => story['name'] }) if story['name'] 
      end
    end
  
    # Finds author of the tracker activity and returns its email
    def get_user_email(project_id, name)
      begin
        set_super_token
        project = PivotalTracker::Project.find project_id.to_i
        project.memberships.all.select{|m| m.name == name }[0].email
      rescue => e
        raise WrongActivityData.new("Can't get email of the Tracker user: #{name} in project id: #{project_id}. " + e)
      end 
    end
    
    # Return PivotalTracker story for given activity    
    def get_story(activity)
      begin 
        set_super_token
        project_id = activity['project_id']
        story_id = activity['stories']['story']['id']
        story = PivotalTracker::Project.find(project_id).stories.find(story_id)
      rescue => e
        raise WrongActivityData.new("Can't get story: #{story_id} from Pivotal Tracker. " + e)
      end
      return story 
    end

    # Return object which maps Redmine project with Tracker project
    def get_mapping(tracker_project_id, label)
      mapping = Mapping.find :first, :conditions=>['tracker_project_id=? AND label=? ', tracker_project_id, label.to_s]
      return mapping
    end    

    # Creates Redmine issues
    def create_issues(activity)
      story = get_story(activity)
      raise WrongActivityData.new("Can't get story with id= #{activity['stories']['story']['id']}") if story.nil?

      # Getting story owners email
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
        next if mapping.try(:project).nil?
        tracker = Tracker.find_by_name mapping.story_types[story.story_type] 
        next if tracker.nil?  
        estimated_hours = mapping.estimations[story.estimate.to_i.to_s].to_i 
       
        # Creating a new Redmine issue
        issue = mapping.project.issues.create(:subject => story.name,
                                              :description => description,
                                              :author_id => author.id,
                                              :tracker_id => tracker.id, 
                                              :status_id => status.id,
                                              :estimated_hours => estimated_hours)

        # Setting value of 'Pivotal Story ID' issue custom field
        issue.pivotal_story_id= story.id
        StoryProject.find_or_create_by_story_id_and_tracker_project_id(story.id, story.project_id)

        # Adding comments (journals)
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
    
    # Updates Redmine issues
    def update_issues( issues, tracker_project_id, params ) 
      issues.each do |issue|
        # Before update checks if mapping still exist (no matter of labels- only projects mapping)
        unless issue.project.mappings.all( :conditions => ["tracker_project_id=?", tracker_project_id] ).empty?
          issue.update_attributes(params)
        end
      end
    end

    # Updates Redmine issues- status and owner when story restarted
    def story_restart(issues, activity)
      status = IssueStatus.find_by_name "Accepted"
      email = get_user_email( activity['project_id'], activity['author'] )
      author = User.find_by_mail email
      update_issues(issues, activity['project_id'], { :status_id => status.id, :assigned_to_id => author.id })    
    end
    
    # Finishes the story when the Redmine issue is closed    
    def finish_story(story_id)
      begin
        set_super_token
        project_id = StoryProject.find_by_story_id(story_id).try(:tracker_project_id)
        story = PivotalTracker::Story.find(story_id, project_id) 
        case story.story_type
          when 'feature'
            story.update( :current_state => 'finished' )
          when 'bug'
            story.update( :current_state => 'finished' )
          when 'chore'  
            story.update( :current_state => 'accepted' )
        end
      rescue => e 
        raise PivotalTrackerError.new("Can't finish the story id:#{story_id}. " + e )     
      end
    end

    private 
    
    # Gets and sets token for Pivotal Tracker 'Super User'
    def set_super_token
       set_token('super_user') if @token.nil?       
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

  # Error to be raised when can't get access to PivotalTracker
  class PivotalTrackerError < StandardError; end;


end

