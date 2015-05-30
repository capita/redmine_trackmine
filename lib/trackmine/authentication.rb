module Trackmine
  module Authentication
    class << self

      def set_token(email)
        credentials = Trackmine::Configuration.new.credentials(email) ||
            raise(MissingCredentials, "Missing credentials for #{email} in trackmine.yml")

        credentials.token ? set_token_from_config(credentials) : set_token_from_email(credentials)
        PivotalTracker::Client.use_ssl = true
      rescue => e
        raise WrongCredentials.new("Wrong Pivotal Tracker credentials in trackmine.yml. #{e}")
      end

      def set_token_from_config(credentials)
        @token = credentials.token
        PivotalTracker::Client.token = @token
      end

      def set_token_from_email(credentials)
        @token = PivotalTracker::Client.token(credentials.email, credentials.password)
      end

    end
  end
end

