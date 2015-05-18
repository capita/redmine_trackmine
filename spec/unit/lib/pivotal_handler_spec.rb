require File.dirname(__FILE__) + '/../../spec_helper'
require 'rack/test'

# describe PivotalHandler do
#   include Rack::Test::Methods
#
#   def app
#     PivotalHandler.new
#   end
#
#   context 'pivotal_callback' do
#     describe 'POST /pivotal_activity.json' do
#
#       context 'when wrong body' do
#         let!(:post_request) { post '/pivotal_activity.json', { a:1 }.to_json }
#
#         it 'returns 202' do
#           expect(last_response.status).to be == 202
#         end
#
#         it 'returns wrong message' do
#           expect(last_response.body).to be == 'It is not a correct Pivotal Tracker message'
#         end
#       end
#
#       context 'when proper body' do
#         before { expect(Trackmine).to receive(:read_activity) }
#
#         let(:story_update) do
#           { kind: 'story_update_activity', highlight: 'started', guid: '1327280_10' }
#         end
#
#         let!(:post_request) { post('/pivotal_activity.json', story_update.to_json, content_type: :json) }
#
#         it 'returns 200' do
#           expect(last_response.status).to be == 200
#         end
#
#         it 'returns success message' do
#           expect(last_response.body).to be == 'Got the activity'
#         end
#       end
#     end
#   end
# end