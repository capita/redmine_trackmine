module Trackmine
  class Credentials

    def initialize(user, configuration)
      self.user = user
      self.configuration = configuration
    end

    def password
      credentials_for_user['password']
    end

    def token
      credentials_for_user['token']
    end

    def email
      credentials_for_user['email']
    end

    private

    attr_accessor :user, :configuration

    def credentials_for_user
      configuration[user]
    end
  end
end