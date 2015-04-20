require_dependency 'issue'

module IssuePatch

  def self.included(klass) # :nodoc:

    klass.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development

      # Finishes story when Issue status changed to 'closed' or 'rejected'
      before_update do |issue|
        if issue.status_id_changed? && issue.status.is_closed?
          if (issue.pivotal_story_id != 0) || (issue.pivotal_project_id != 0)
            begin
              Trackmine.finish_story( issue.pivotal_project_id, issue.pivotal_story_id )
            rescue => e
              TrackmineMailer.deliver_error_mail("Error while closing story. Pivotal Project ID:'#{issue.pivotal_project_id}', Story ID:'#{issue.pivotal_story_id}',: " + e)
            end
          end
        end
      end

      def self.find_by_story_id(story_id)
        Issue.joins({:custom_values => :custom_field})
          .where("custom_fields.name=? AND custom_values.value=?", 'Pivotal Story ID', story_id.to_s).first
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

    end

  end

end
