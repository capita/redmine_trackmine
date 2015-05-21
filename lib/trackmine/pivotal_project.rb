module Trackmine
  class PivotalProject

    def initialize(project_id)
      self.project_id = project_id
      Trackmine.set_super_token
    end

    def project
      PivotalTracker::Project.find(project_id)
    rescue => e
      raise WrongActivityData, "Can't get Pivotal Project id: #{project_id}. #{e}"
    end

    def story(story_id)
      project.stories.find(story_id)
    rescue => e
      raise WrongActivityData, "Can't get story: #{story_id} from Pivotal Tracker project: #{project_id}. #{e}"
    end

    def labels
      project.stories.all
        .select { |s| !s.labels.nil?}
          .map { |s| Unicode.downcase(s.labels) }.join(',').split(',').uniq
    end

    def participant_email(name)
      project.memberships.all.select { |m| m.name == name }[0].email
    rescue => e
      raise WrongActivityData, "Can't get Tracker user: #{name} in project id: #{project_id}. #{e}"
    end

    private

    attr_accessor :project_id

  end
end