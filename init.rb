require 'redmine'
require 'pivotal_tracker'

# Adds relationship between Project and Mapping 
Project.class_eval do
  has_many :mappings
end

# Adds finding Issue by Pivotal Story ID
Issue.class_eval do
  after_save :finish_pivotal_story

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
  
  private

  def finish_pivotal_story
    if self.status.is_closed?  && self.pivotal_story_id!=0
      Trackmine.finish_story( self.pivotal_story_id )
    end
  end
end


Redmine::Plugin.register :redmine_trackmine do
  name 'Redmine Trackmine plugin'
  author 'Piotr Brudny'
  description 'This plugin integrates Redmine projects with Pivotal Tracker'
  version '0.0.1'
  
  menu :admin_menu, :mapping, { :controller => :mappings, :action => 'index' }, :caption =>'Trackmine', :last => true
end
