module Trackmine
  class Activity

    def initialize(activity)
      self.activity = activity
    end

    def project_id
      activity['project']['id'] if activity['project']
    end

    def story_id
      activity['primary_resources'].select { |r| r['kind'] == 'story' }.first['id'] if activity['primary_resources']
    end

    def story_started?
      activity['highlight'] == 'started' && activity['kind'] == 'story_update_activity'
    end

    def story_edited?
      activity['highlight'] == 'edited' && activity['kind'] == 'story_update_activity'
    end

    def author_name
      activity['performed_by']['name']
    end

    def author
      email = project.participant_email(author_name)
      User.find_by_mail(email)
    end

    def project
      @pivotal_project ||= Trackmine::PivotalProject.new(project_id)
    end

    def new_value
      activity['changes'].select { |r| r['kind'] == 'story' }.first['new_values'] if activity['changes']
    end

    def story
      @story ||= project.story(story_id)
    end

    private

    attr_accessor :activity

  end
end