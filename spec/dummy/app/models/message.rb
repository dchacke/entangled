class Message < ActiveRecord::Base
  include Entangled::Model
  entangle

  validates :body, presence: true
end
