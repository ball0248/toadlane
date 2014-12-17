class MessagesController < ApplicationController
  before_filter :authenticate_user!

  def create
    user = User.find message_params[:user_id]
    current_user.send_message user, message_params[:body], message_params[:subject]
    redirect_to :back
  end

  private
    def message_params
      params.require(:message).permit(:user_id, :subject, :body)
    end
end
