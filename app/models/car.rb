class Car < ApplicationRecord
  belongs_to :user
  has_many :journeys
  has_many :availabilities

  validates :bio, :travel_distance, :price_hour, presence: true


end
