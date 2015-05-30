module Trackmine
  class StoryFinisher

    def initialize(story)
      self.story = story
    end

    def run
      finish_story
    rescue => e
      raise PivotalTrackerError, "Can't finish the story id:#{story_id}. #{e}"
    end

    def finish_story
      case story.story_type
        when 'feature' then story.update(current_state: 'finished')
        when 'bug' then story.update(current_state: 'finished')
        when 'chore' then story.update(current_state: 'accepted')
      end
    end

    private

    attr_accessor :story
  end
end