class List < ActiveRecord::Base
  include Entangled::Model
  entangle

  has_many :items, dependent: :destroy
end
