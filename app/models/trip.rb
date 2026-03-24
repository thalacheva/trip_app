class Trip < ApplicationRecord
  validates :name, presence: true, length: { maximum: 100 }
  validates :image_url, presence: true, length: { maximum: 100 }
  validates :short_description, presence: true, length: { maximum: 255 }
  validates :long_description, presence: true, length: { maximum: 500 }
  validates :rating, presence: true, inclusion: { in: 1..5 }
end
