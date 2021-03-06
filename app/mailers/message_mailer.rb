class MessageMailer < ApplicationMailer
  add_template_helper(EmailHelper)

  def new_message(receiver, message, subject, sender, conversation_id)
    @receiver = receiver
    @message = message
    @subject = subject
    @sender = sender
    @message_url = dashboard_message_url(conversation_id)

    if Rails.env.production?
      reply_to = "dcffb0d65f0f2b20786b5d8056648023+#{conversation_id}@inbound.postmarkapp.com"
    else
      reply_to = "c8b7ddb781077404c27659d9ef85d353+#{conversation_id}@inbound.postmarkapp.com"
    end

    if @subject.present?
      subject = @subject
    else
      subject = "New Message from #{@sender.name || @sender.email}"
    end

    mail( to: @receiver.email,
          subject: subject,
          reply_to: reply_to)
  end
end
