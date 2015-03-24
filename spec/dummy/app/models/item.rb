class Item < ActiveRecord::Base
  include Entangled::Model
  entangle

  belongs_to :list, required: true

  validates :name, presence: true
end
