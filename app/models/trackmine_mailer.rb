class TrackmineMailer < ActionMailer::Base

  def error_mail(error_message)
    @error_message = error_message

    mail(
      to: Trackmine.error_notification['recipient'],
      subject: 'Trackmine error occurred',
      from: Trackmine.error_notification['from']
    )
  end
end


