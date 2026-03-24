class TripSerializer < ActiveModel::Serializer
  attributes :id, :name, :image_url, :short_description, :long_description, :rating
end
