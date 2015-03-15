class ItemsController < ApplicationController
  include Entangled::Controller

  def index
    broadcast do
      @items = List.find(params[:list_id]).items
    end
  end

  def create
    broadcast do
      @item = List.find(params[:list_id]).items.create(item_params)
    end
  end

  def show
    broadcast do
      @item = Item.find(params[:id])
    end    
  end

  def update
    broadcast do
      @item = Item.find(params[:id])
      @item.update(item_params)
    end
  end

  def destroy
    broadcast do
      @item = Item.find(params[:id]).destroy
    end
  end

private
  def item_params
    params.require(:item).permit(:name, :complete)
  end
end
