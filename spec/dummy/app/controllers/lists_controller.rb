class ListsController < ApplicationController
  include Entangled::Controller

  def index
    broadcast do
      @lists = List.all
    end
  end
end
