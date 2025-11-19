class ContactMessagesController < ApplicationController
  def new
    @contact_message = ContactMessage.new
  end

  def create
    @contact_message = ContactMessage.new(contact_params)
    if @contact_message.save
      # send notification email to site owner (use deliver_later if Active Job is configured)
      begin
        ContactMailer.notify(@contact_message).deliver_now
      rescue => e
        Rails.logger.error "ContactMailer error: #{e.message}"
      end

      redirect_to root_path, notice: "Thanks — your message has been sent."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def contact_params
    params.require(:contact_message).permit(:name, :email, :message)
  end
end
