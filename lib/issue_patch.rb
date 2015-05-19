require_dependency 'issue'

module IssuePatch

  def self.included(klass) # :nodoc:

    klass.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development

      # before_update { |issue| finish_story_when_closed_or_rejected(issue) }

      def self.find_by_story_id(story_id)
        Issue.joins({custom_values: :custom_field})
          .where("custom_fields.name=? AND custom_values.value=?", 'Pivotal Story ID', story_id.to_s)
      end

      def pivotal_custom_value(name)
        CustomValue.joins(:custom_field).where(custom_fields: {name: name}, customized_id: self.id).first
      end

      def pivotal_project_id=(project_id)
        pivotal_custom_value('Pivotal Project ID').update_attributes(value: project_id.to_s)
      end

      def pivotal_project_id
        pivotal_custom_value('Pivotal Project ID').try(:value).to_i
      end

      def pivotal_story_id=(story_id)
        pivotal_custom_value('Pivotal Story ID').update_attributes(value: story_id.to_s)
      end

      def pivotal_story_id
        pivotal_custom_value('Pivotal Story ID').try(:value).to_i
      end

      def finish_story_when_closed_or_rejected
        if issue_closed? && pivotal_assigned?
          begin
            Trackmine.finish_story(pivotal_project_id, pivotal_story_id)
          rescue => e
            TrackmineMailer.deliver_error_mail("Error while closing story. Pivotal Project ID:'#{pivotal_project_id}', Story ID:'#{pivotal_story_id}',: " + e)
          end
        end
      end

      def issue_closed?
        status_id_changed? && status.is_closed?
      end

      def pivotal_assigned?
        pivotal_story_id != 0 || pivotal_project_id != 0
      end
    end
  end
end
