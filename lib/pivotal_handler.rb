require 'sinatra'

class PivotalHandler < Sinatra::Base

  post '/pivotal_message.xml' do
    message = request.body.read.strip
    message_hash = Hash.from_xml(message)
    return [202, "It is not a correct Pivotal Tracker message"] if message_hash['activity'].nil?

    begin
      authors_email = Trackmine.get_authors_email(message_hash["activity"])
    rescue
      return [202, "Can't get authors email"] 
    end

    [200, "Got the stuff"]
  end

end


