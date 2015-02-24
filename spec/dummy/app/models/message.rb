class Message < ActiveRecord::Base
  include Entangled::Model
  entangle
end
