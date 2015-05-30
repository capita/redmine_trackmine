module Trackmine
  class IssuesCreator

    def initialize(activity)
      self.activity = activity
    end

    def story
      activity.story
    end

    def labels
      story.labels.to_s.split(',') || ['']
    end

    def issue_attributes
      {
        project_id: activity.project_id,
        story: story,
        author: activity.author
      }
    end

    def run
      labels.each { |label| IssueCreator.new(label, issue_attributes).run }
    end

    private

    attr_accessor :activity
  end
end
