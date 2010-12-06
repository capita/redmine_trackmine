require 'sinatra'

class PivotalHandler < Sinatra::Base

  post '/pivotal_message.xml' do
    message = request.body.read.strip
    message_hash = Hash.from_xml(message)
    return [202, "It is not a correct Pivotal Tracker message"] if message_hash['activity'].nil?
    begin
      Trackmine.read_activity message_hash['activity'] 
    rescue
      return [202, "Wrong activity data"] 
    end

    [200, "Got the stuff"]
  end

end


