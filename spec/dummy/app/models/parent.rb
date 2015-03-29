class Parent < ActiveRecord::Base
  include Entangled::Model
  entangle

  has_many :children, dependent: :destroy
  belongs_to :grandmother, required: true
  belongs_to :grandfather, required: true
end
