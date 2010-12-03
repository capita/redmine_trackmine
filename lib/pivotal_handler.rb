require 'sinatra'

class PivotalHandler < Sinatra::Base

  post '/pivotal_message.xml' do
    message = request.body.read.strip
    message_hash = Hash.from_xml(message)
    return [202, "It is not a correct Pivotal Tracker message"] if message_hash['activity'].nil?

    #TODO: it want pass until I finish fakeweb    
    authors_email = Trackmine.get_author(message_hash["activity"])
    return [202, "Can't get authors email"] if authors_email.nil?

    [200, "Got the stuff"]
  end

end


