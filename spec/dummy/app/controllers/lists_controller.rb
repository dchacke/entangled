class ListsController < ApplicationController
  include Entangled::Controller

  def index
    broadcast do
      @lists = List.all
    end
  end

  def create
    broadcast do
      @list = List.create(list_params)
    end
  end

  def show
    broadcast do
      @list = List.find(params[:id])
    end
  end

  def update
    broadcast do
      @list = List.find(params[:id])
      @list.update(list_params)
    end
  end

  def destroy
    broadcast do
      @list = List.find(params[:id]).destroy
    end
  end

private
  def list_params
    params.require(:list).permit(:name)
  end
end
