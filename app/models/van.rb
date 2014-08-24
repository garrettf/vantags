class Van < ActiveRecord::Base
  include Taggable
  validates_presence_of :make, :model
end
