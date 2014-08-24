class Van < ActiveRecord::Base
  validates_presence_of :make, :model
end
