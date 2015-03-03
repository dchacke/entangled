# This controller serves as fully restful example
# controller with all five actions
class MessagesController < ApplicationController
  include Entangled::Controller

  def index
    broadcast do
      @messages = Message.all
    end
  end

  def show
    broadcast do
      @message = Message.find(params[:id])
    end
  end

  def create
    broadcast do
      @message = Message.create(message_params)
    end
  end

  def update
    broadcast do
      @message = Message.find(params[:id])
      @message.update(message_params)
    end
  end

  def destroy
    broadcast do
      Message.find(params[:id]).destroy
    end
  end

private
  def message_params
    params.require(:message).permit(:body)
  end
end
