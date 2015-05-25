module Trackmine
  module Authentication

    def self.set_token(email)
      credentials = Trackmine::Configuration.new.credentials(email)
      raise MissingCredentials.new("Missing credentials for #{email} in trackmine.yml") if credentials.nil?
      begin
        if (credentials.token)
          @token = credentials.token
          PivotalTracker::Client.token = @token
        else
          @token = PivotalTracker::Client.token(credentials.email, credentials.password)
        end
        PivotalTracker::Client.use_ssl = true # to access pivotal projects which use https
      rescue => e
        raise WrongCredentials.new("Wrong Pivotal Tracker credentials in trackmine.yml. #{e}")
      end
    end

  end
end