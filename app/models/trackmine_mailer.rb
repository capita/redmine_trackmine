class TrackmineMailer < ActionMailer::Base

  def error_mail(exception)
    recipients "piotrek@therock.pl"
    from "Trackmine Notifications <no-reply@capita.de>" 
    subject "Trackmine error occurred" 
    sent_on Time.now 
    body :exception => exception
  end  
end


