require_dependency 'issue'

# Patches Redmine's Issues dynamically. 
module IssuePatch

  def self.included(klass) # :nodoc:
    # Adds finding Issue by Pivotal Story ID
    klass.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development  

      # When Issue status changed to 'closed' or 'rejected' finishes story 
      before_update do |issue|
        if issue.status_id_changed?
          if issue.status.is_closed?  && issue.pivotal_story_id != 0
            begin
              Trackmine.finish_story( issue.pivotal_story_id )
            rescue => e
              TrackmineMailer.deliver_error_mail("Error while closing story: " + e)
            end
          end  
        end
      end

      def self.find_by_story_id(story_id)
        Issue.scoped(:joins => {:custom_values => :custom_field},
                     :conditions => ["custom_fields.name=? AND custom_values.value=?", 'Pivotal Story ID', story_id.to_s ],
                     :readonly => false)
      end
      
      def pivotal_custom_value
        cv = CustomValue.first :joins => :custom_field,
                               :readonly => false,          
                               :conditions => { :custom_values => { :customized_id => self.id, 
                                                                    :customized_type => 'Issue' },
                                                                    :custom_fields => { :name => 'Pivotal Story ID' } }
      
        raise Exception.new("Can't find 'Pivotal Story ID' custom field for issue: '#{self.subject}'") if cv.nil?
        return cv
      end

      # Setter
      def pivotal_story_id=(story_id)
        pivotal_custom_value.update_attributes :value => story_id.to_s
      end

      # Getter  
      def pivotal_story_id
        pivotal_custom_value.value.to_i
      end
    end

  end

end
