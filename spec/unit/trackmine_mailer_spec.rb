require File.dirname(__FILE__) + '/../spec_helper'

describe TrackmineMailer do
  describe '.error_email' do
    let(:error_message) { 'Something went wrong' }
    let(:email) { TrackmineMailer.error_mail(error_message) }

    it 'delivers email' do
      expect {email.deliver }.to change { ActionMailer::Base.deliveries.count }
    end

    it 'has right content' do
      expect(email.to.first).to eql Trackmine.error_notification['recipient']
      expect(email.subject).to eql 'Trackmine error occurred'
      expect(email.body).to match /Got error from Trackmine/
      expect(email.body).to match /Something went wrong/
    end
  end
end
