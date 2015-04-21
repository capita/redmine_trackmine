require_dependency 'project'

module ProjectPatch

  def self.included(klass) # :nodoc:
    klass.class_eval do
      unloadable
      has_many :mappings, dependent: :destroy
    end
  end

end
