class MessagesController < ApplicationController
  before_action :require_login

  def index
    # Inbox: show latest received messages (grouping by sender is optional)
    @messages = current_user.received_messages.includes(:sender).order(created_at: :desc).limit(50)
  end

  def new
    @recipient = User.find_by(id: params[:recipient_id])
    @message = Message.new
  end

  def create
    @message = current_user.sent_messages.build(message_params)
    if @message.save
      redirect_to conversation_messages_path(@message.recipient_id), notice: 'Message sent.'
    else
      flash.now[:alert] = 'Unable to send message.'
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    m = current_user.sent_messages.find_by(id: params[:id]) || current_user.received_messages.find_by(id: params[:id])
    return head :not_found unless m
    m.destroy
    redirect_to messages_path, notice: 'Message deleted.'
  end

  # Conversation between current_user and another user
  def conversation
    other = User.find_by(id: params[:user_id])
    return redirect_to messages_path, alert: 'User not found' unless other
    @other = other
    @messages = Message.between(current_user, other)
    # mark unread messages as read for current_user
    Message.where(sender: other, recipient: current_user, read_at: nil).update_all(read_at: Time.current)
    @message = Message.new
  end

  private
  def message_params
    params.require(:message).permit(:recipient_id, :body)
  end
end
