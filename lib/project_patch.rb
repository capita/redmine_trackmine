require_dependency 'project'

# Patches Redmine's Project dynamically. 
module ProjectPatch

  def self.included(klass) # :nodoc:
    klass.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development 
      has_many :mappings, :dependent => :destroy
    end
  end

end
