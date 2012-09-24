

# Patches Redmine's Project dynamically.
module RedmineTrackmine
  module Patches
    module ProjectPatchy

      def self.included(klass) # :nodoc:
        klass.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
          has_many :mappings, :dependent => :destroy
        end
      end

    end
  end
end
