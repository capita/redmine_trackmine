require File.dirname(__FILE__) + '/../../spec_helper'
require 'rack/test'

describe PivotalHandler do
  include Rack::Test::Methods

  def app
    PivotalHandler.new
  end

  context 'pivotal_callback' do
    describe 'POST /result.json' do
      let(:token) { 'abc123' }

      context 'when wrong body' do
        let!(:post_request) { post "/result.json?token=#{token}", { a:1 }.to_json }

        it 'returns 202' do
          expect(last_response.status).to be == 202
        end

        it 'returns wrong message' do
          expect(last_response.body).to be == 'Wrong request!'
        end
      end

      context 'when proper body' do
        let(:pivotal_response) do
          {
              'status' => 'pending',
              'checksum' => '53753707eec4e3e79e5383dffd01af17cc09c048',
              'request_id' => '6b53139e-61d7-11e1-980d-12313b064e2b'
          }
        end

        let(:result) do
          {
              'status' => 'infected',
              'checksum' => 'bec1b52d350d721c7e22a6d4bb0a92909893a3ae',
              'virus' => ['eicar-test-signature'],
              'request_id' => '6b53139e-61d7-11e1-980d-12313b064e2b'
          }
        end
        let!(:virus_scan) { create :virus_scan, status: 'pending', pivotal_response: pivotal_response, token: token }
        let!(:post_request) { post("/result.json?token=#{token}", result.to_json, content_type: :json) }

        it 'returns 200' do
          expect(last_response.status).to be == 200
        end

        it 'returns success message' do
          expect(last_response.body).to be == 'Got the result!'
        end
      end
    end
  end
end