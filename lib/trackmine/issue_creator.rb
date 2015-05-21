module Trackmine
  class IssueCreator

    def initialize(project, label, issue_params)
      self.project = project
      self.label = label
      self.issue_params = issue_params
    end

    def run
      create_issue
    end

    def mapping_params
      {
        tracker_id: tracker.id,
        estimated_hours: estimated_hours
      }
    end

    def mapping
      @mapping ||= Trackmine.get_mapping(project.id, Unicode.downcase(label))
    end

    def custom_field_pivotal_story_id
      CustomField.find_by(name: 'Pivotal Story ID')
    end

    def custom_field_pivotal_project_id
      CustomField.find_by(name: 'Pivotal Project ID')
    end

    def create_issue
      return if mapping.try(:project).nil?
      tracker = Tracker.find_by_name mapping.story_types[story.story_type]
      return if tracker.nil?
      estimated_hours = mapping.estimations[story.estimate.to_s].to_i

      # Creating a new Redmine issue
      issue = mapping.project.issues.create!(issue_params.merge(mapping_params))
      CustomValue.create!(
          customized_type: Issue,
          custom_field_id: custom_field_pivotal_project_id.id,
          customized_id: issue.id,
          value: story.project_id
      )

      CustomValue.create!(
          customized_type: Issue,
          custom_field_id: custom_field_pivotal_story_id.id,
          customized_id: issue.id,
          value: story.id
      )

      # Adding comments (journals)
      story.notes.all.each do |note|
        user = User.find_by_mail get_user_email(story.project_id, note.author)
        journal = issue.journals.new(notes: note.text)
        journal.user_id = user.id unless user.nil?
        journal.save
      end
    end

    private

    attr_accessor :project, :label, :issue_params

  end
end
