# This controller serves as fully restful example
# controller with all five actions
class MessagesController < ApplicationController
  include Entangled::Controller
  before_action :destroy_all, only: :create, if: -> { Rails.env.test? }

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
      Message.create(message_params)
    end
  end

  def update
    broadcast do
      Message.find(params[:id]).update(message_params)
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

  # For test purposes
  def destroy_all
    Message.destroy_all
  end
end
