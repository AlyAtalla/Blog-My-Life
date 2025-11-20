class ContactMailer < ApplicationMailer
  default to: ENV.fetch("CONTACT_RECEIVER_EMAIL", "aliatalla93@gmail.com")

  def notify(contact_message)
    @contact_message = contact_message
    mail(from: @contact_message.email, subject: "New contact from #{@contact_message.name}")
  end
end
