module Trackmine
  class Configuration

    def initialize
      load_configuration
    end

    def trackmine_path
      @trackmine_path ||= File.join(Rails.root, 'config', 'trackmine.yml')
    end

    def load_configuration
      unless File.exist?(trackmine_path)
        raise MissingTrackmineConfig, 'Missing trackmine.yml configuration file in /config'
      end
      self.config = YAML.load_file(trackmine_path)
    end

    def error_notification
      config['error_notification']
    end

    def credentials(user)
      Trackmine::Credentials.new(user, config)
    end

    private

    attr_accessor :config
  end
end