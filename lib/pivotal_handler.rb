require 'sinatra'

class PivotalHandler < Sinatra::Base

  get '/hello/:name' do
    "Hello #{params[:name]}"
  end

  post '/pivotal_message.xml' do
    message = request.body.read.strip
#    message_hash = Hash.from_xml(message)
#    activity = message_hash["activity"]
#    if activity["event_type"] == "story_create"
#      #Issue
#    end 
    
    return [200, "Got the stuff"]
  end

end


