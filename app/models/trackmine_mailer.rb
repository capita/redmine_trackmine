class TrackmineMailer < ActionMailer::Base

  def error_mail(exception)
    recipients Trackmine.error_notification['recipient']
    from Trackmine.error_notification['from']
    subject "Trackmine error occurred" 
    sent_on Time.now 
    body :exception => exception
  end  
end


