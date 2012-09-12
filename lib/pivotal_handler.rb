require 'sinatra'

class PivotalHandler < Sinatra::Base

  post '/' do
#    message = request.body.read.strip # doesn't work with xml sent from PivotalTracker
    message = request.env["RAW_POST_DATA"] # TODO: make test passing it
    message_hash = Hash.from_xml(message)
    return [202, "It is not a correct Pivotal Tracker message"] if message_hash['activity'].nil?
    if message_hash['activity']['event_type'] == 'story_update'
      begin
        Trackmine.read_activity message_hash['activity']
      rescue => e
        # Sending email when something is wrong
        TrackmineMailer.deliver_error_mail("Error while reading activity message from Pivotal Tracker: #{e}")
        return [202, "Not supported activity"]
      end
      return [200, "Got the activity"]
    else
      return [202, "Not supported event_type"]
    end
  end
end


