require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')
require 'sinatra'

class PivotalHandler < Sinatra::Base

  post '/pivotal_activity.json' do
    pivotal_body = JSON.parse(request.body.read.to_s)

    return [202, 'It is not a correct Pivotal Tracker message'] if pivotal_body['kind'].nil?
    if pivotal_body['kind'] == 'story_update_activity'
      begin
        handler_logger 'Got the post request from PivotalTracker'
        Trackmine.read_activity(Trackmine::Activity.new(pivotal_body))
      rescue => e
        handler_logger("Can't consume the request from PivotalTracker: #{e}")
        TrackmineMailer.error_mail("Error while reading activity message from Pivotal Tracker: #{e}").deliver

        return [202, 'Not supported activity']
      end
      return [200, 'Got the activity']
    else
      return [202, 'Not supported event_type']
    end
  end

  private

  def handler_logger(message)
    Rails.logger.tagged('PivotalHandler') { Rails.logger.info message }
  end

end