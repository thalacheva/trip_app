RSpec.describe Trip, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      trip = Trip.new(name: "Trip Name",
                      image_url: "https://example.com/photo.jpg",
                      short_description: "A short description",
                      long_description: "A longer description " * 5,
                      rating: 4)

      expect(trip).to be_valid
    end

    it "is invalid without a name" do
      trip = Trip.new(name: nil,
                      image_url: "https://example.com/photo.jpg",
                      short_description: "A short description",
                      long_description: "A longer description " * 5,
                      rating: 4)

      expect(trip).to be_invalid
      expect(trip.errors.full_messages).to include("Name can't be blank")
    end

    it "is invalid without an image URL" do
      trip = Trip.new(name: "Trip Name",
                      image_url: nil,
                      short_description: "A short description",
                      long_description: "A longer description " * 5,
                      rating: 4)

      expect(trip).to be_invalid
      expect(trip.errors.full_messages).to include("Image url can't be blank")
    end

    it "is invalid without a short description" do
      trip = Trip.new(name: "Trip Name",
                      image_url: "https://example.com/photo.jpg",
                      short_description: nil,
                      long_description: "A longer description " * 5,
                      rating: 4)

      expect(trip).to be_invalid
      expect(trip.errors.full_messages).to include("Short description can't be blank")
    end

    it "is invalid without a long description" do
      trip = Trip.new(name: "Trip Name",
                      image_url: "https://example.com/photo.jpg",
                      short_description: "A short description",
                      long_description: nil,
                      rating: 4)

      expect(trip).to be_invalid
      expect(trip.errors.full_messages).to include("Long description can't be blank")
    end

    it "is invalid with a rating less than 1" do
      trip = Trip.new(name: "Trip Name",
                      image_url: "https://example.com/photo.jpg",
                      short_description: "A short description",
                      long_description: "A longer description " * 5,
                      rating: 0)

      expect(trip).to be_invalid
      expect(trip.errors.full_messages).to include("Rating must be between 1 and 5")
    end

    it "is invalid with a rating greater than 5" do
      trip = Trip.new(name: "Trip Name",
                      image_url: "https://example.com/photo.jpg",
                      short_description: "A short description",
                      long_description: "A longer description " * 5,
                      rating: 6)

      expect(trip).to be_invalid
      expect(trip.errors.full_messages).to include("Rating must be between 1 and 5")
    end

    it "is invalid with an invalid image URL" do
      trip = Trip.new(name: "Trip Name",
                      image_url: "not a url",
                      short_description: "A short description",
                      long_description: "A longer description " * 5,
                      rating: 4)

      expect(trip).to be_invalid
      expect(trip.errors.full_messages).to include("Image url is not a valid URL")
    end
  end

  describe "scopes" do
    def valid_trip_attributes(overrides = {})
      {
        name: "Trip #{SecureRandom.hex(4)}",
        image_url: "https://example.com/photo.jpg",
        short_description: "A short description",
        long_description: "A longer description " * 5,
        rating: 4
      }.merge(overrides)
    end

    it "returns trips with a name containing the search term" do
      trip = Trip.create!(valid_trip_attributes(name: "Unique Park Alpha"))
      Trip.create!(valid_trip_attributes(name: "Other Place"))

      expect(Trip.search_by_name("Unique")).to include(trip)
    end

    it "returns trips with a rating greater than or equal to the minimum rating" do
      [3, 4, 5].each do |rating|
        Trip.create!(valid_trip_attributes(rating: rating))
      end

      expect(Trip.with_min_rating(4).pluck(:rating)).to eq([4, 5])
    end

    it "returns trips sorted by name by default" do
      ["B", "A", "C"].each do |name|
        Trip.create!(valid_trip_attributes(name: name))
      end

      expect(Trip.order_by(nil).pluck(:name)).to eq(["A", "B", "C"])
    end

    it "returns trips sorted by rating asc" do
      [3, 4, 5].each do |rating|
        Trip.create!(valid_trip_attributes(rating: rating))
      end

      expect(Trip.order_by("rating_asc").pluck(:rating)).to eq([3, 4, 5])
    end

    it "returns trips sorted by rating desc" do
      [3, 4, 5].each do |rating|
        Trip.create!(valid_trip_attributes(rating: rating))
      end

      expect(Trip.order_by("rating_desc").pluck(:rating)).to eq([5, 4, 3])
    end
  end
end
