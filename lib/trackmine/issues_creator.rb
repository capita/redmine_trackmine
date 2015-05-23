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

    def author
      activity.author
    end

    def description
      story.url + "\r\n" + story.description
    end

    def status
      IssueStatus.find_by(name: 'Accepted') ||
          raise(WrongTrackmineConfiguration.new("Can't find Redmine IssueStatus: 'Accepted' "))
    end

    def issue_params
      {
        subject: story.name,
        description: description,
        author_id: author.id,
        assigned_to_id: author.id,
        status_id: status.id,
        priority_id: 1,
      }
    end

    def run
      labels.map { |label| IssueCreator.new(activity.project_id, story, label, issue_params).run }
    end

    private

    attr_accessor :activity
  end
end
