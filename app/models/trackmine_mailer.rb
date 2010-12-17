class TrackmineMailer < ActionMailer::Base

  def error_mail(exceptions)
    recipients "piotrek@therock.pl"
    from "My Awesome Site Notifications <notifications@example.com>" 
    subject "Trackmine error occurred" 
    sent_on Time.now 
    body {}#{:exceptions => "tak" } 
  end  
end
