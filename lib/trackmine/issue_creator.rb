module Trackmine
  class IssueCreator

    def initialize(project_id, story, label, issue_params)
      self.project_id = project_id
      self.label = label
      self.issue_params = issue_params
      self.story = story
    end

    def run
      create_issue
      # create_custom_values
      # add_comments
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

    def custom_field_pivotal_story_id
      CustomField.find_by(name: 'Pivotal Story ID')
    end

    def custom_field_pivotal_project_id
      CustomField.find_by(name: 'Pivotal Project ID')
    end

    def tracker
      Tracker.find_by_name(mapping.story_types[story.story_type])
    end

    def estimated_hours
      mapping.estimations[story.estimate.to_s].to_i
    end

    def issue
      @issue
    end

    def create_custom_values
      CustomValue.create!(
          customized_type: Issue,
          custom_field_id: custom_field_pivotal_project_id.id,
          customized_id: issue.id,
          value: project_id
      )

      CustomValue.create!(
          customized_type: Issue,
          custom_field_id: custom_field_pivotal_story_id.id,
          customized_id: issue.id,
          value: story.id
      )
    end

    def add_comments
      story.notes.all.each do |note|
        user = User.find_by_mail(get_user_email(story.project_id, note.author))
        journal = issue.journals.new(notes: note.text)
        journal.user_id = user.id unless user.nil?
        journal.save
      end
    end

    def create_issue
      return if mapping.try(:project).nil?
      return if tracker.nil?
      @issue = mapping.project.issues.create!(issue_params.merge(mapping_params))
      create_custom_values
      add_comments
      return @issue
    end

    private

    attr_accessor :project_id, :label, :issue_params, :story

  end
end
