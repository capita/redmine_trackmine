module Trackmine
  class IssueCreator

    def initialize(label, issue_attributes)
      self.label = label
      self.issue_attributes = issue_attributes
    end

    def run
      create_issue
      add_comments
    end

    def description
      story.url + "\r\n" + story.description
    end

    def status
      IssueStatus.find_by(name: ACCEPTED_STATUS) ||
          raise(WrongTrackmineConfiguration, "Can't find Redmine IssueStatus: #{ACCEPTED_STATUS} ")
    end

    def issue_params
      {
        subject: story.name,
        description: description,
        author_id: author.id,
        assigned_to_id: author.id,
        status_id: status.id,
        priority_id: 1,
      }
    end

    def story
      issue_attributes[:story]
    end

    def project_id
      issue_attributes[:project_id]
    end

    def author
      issue_attributes[:author]
    end

    def mapping_params
      {
        tracker_id: tracker.id,
        estimated_hours: estimated_hours
      }
    end

    def mapping
      @mapping ||= Trackmine.get_mapping(project_id, Unicode.downcase(label))
    end

    def tracker
      Tracker.find_by_name(mapping.story_types[story.story_type])
    end

    def estimated_hours
      mapping.estimations[story.estimate.to_s].to_i
    end

    def add_comments
      story.notes.all.each do |note|
        user = User.find_by_mail(get_user_email(story.project_id, note.author))
        journal = issue.journals.create(notes: note.text, user: user)
      end
    end

    def create_issue
      return if mapping.try(:project).nil?
      return if tracker.nil?
      issue = mapping.project.issues.create!(issue_params.merge(mapping_params))
      Trackmine::CustomValuesCreator.new(project_id, story.id, issue.id).run
    end

    private

    attr_accessor :label, :issue_attributes
  end
end
