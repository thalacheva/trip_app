class Trip < ApplicationRecord
  validates :name, presence: true, length: { maximum: 100 }
  validates :image_url, presence: true, length: { maximum: 100 }
  validates :short_description, presence: true, length: { maximum: 255 }
  validates :long_description, presence: true, length: { maximum: 500 }
  validates :rating, presence: true, inclusion: { in: 1..5 }

  scope :search_by_name, -> (name) { where("name ILIKE ?", "%#{name}%") if name.present? }
  scope :with_min_rating, -> (rating) { where("rating >= ?", rating) if rating.present? }
  scope :order_by, -> (sort) {
    case sort
    when 'rating_asc' then order(rating: :asc)
    when 'rating_desc' then order(rating: :desc)
    else order(name: :asc)
    end
  }
end
