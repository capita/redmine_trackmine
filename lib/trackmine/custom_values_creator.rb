module Trackmine
  class CustomValuesCreator

    def initialize(project_id, story_id, issue_id)
      self.project_id = project_id
      self.story_id = story_id
      self.issue_id = issue_id
    end

    def run
      create_custom_values
    end

    def custom_field_pivotal_story_id
      CustomField.find_by(name: 'Pivotal Story ID').id
    end

    def custom_field_pivotal_project_id
      CustomField.find_by(name: 'Pivotal Project ID').id
    end

    def create_custom_values
      CustomValue.create!(
          customized_type: Issue,
          custom_field_id: custom_field_pivotal_project_id,
          customized_id: issue_id,
          value: project_id
      )

      CustomValue.create!(
          customized_type: Issue,
          custom_field_id: custom_field_pivotal_story_id,
          customized_id: issue_id,
          value: story_id
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

    private

    attr_accessor :project_id, :story_id, :issue_id
  end
end
