require_dependency 'issue'

# Patches Redmine's Issues dynamically. 
module IssuePatch

  def self.included(klass) # :nodoc:
  
    klass.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development  

      # When Issue status changed to 'closed' or 'rejected' finishes story 
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

      # finding Issue by Pivotal Story ID
      def self.find_by_story_id(story_id)
        Issue.scoped(:joins => {:custom_values => :custom_field},
                     :conditions => ["custom_fields.name=? AND custom_values.value=?", 'Pivotal Story ID', story_id.to_s ],
                     :readonly => false)
      end
      
      def pivotal_custom_value(name)
        CustomValue.first :joins => :custom_field,
                          :readonly => false,          
                          :conditions => { :custom_values => { :customized_id => self.id, 
                                                               :customized_type => 'Issue' },
                                                               :custom_fields => { :name => name } }
      end
    
      # Pivotal Project ID setter
      def pivotal_project_id=(project_id)
        pivotal_custom_value('Pivotal Story ID').update_attributes :value => project_id.to_s
      end

      # Pivotal Project ID getter  
      def pivotal_project_id
        pivotal_custom_value('Pivotal Project ID').try(:value).to_i
      end

      # Pivotal Story ID setter
      def pivotal_story_id=(story_id)
        pivotal_custom_value('Pivotal Story ID').update_attributes :value => story_id.to_s
      end

      # Pivotal Story ID getter  
      def pivotal_story_id
        pivotal_custom_value('Pivotal Story ID').try(:value).to_i
      end

    end

  end

end
