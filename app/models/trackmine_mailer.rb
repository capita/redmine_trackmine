class TrackmineMailer < ActionMailer::Base

  def error_mail(exception)
    @exception = exception

    mail(
      to: Trackmine.error_notification['recipient'],
      subject: 'Trackmine error occurred',
      from: Trackmine.error_notification['from']
    )
  end
end


