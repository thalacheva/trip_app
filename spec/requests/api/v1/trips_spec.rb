RSpec.describe "Api::V1::Trips", type: :request do
  def valid_trip_attributes(overrides = {})
    {
      name: "Trip #{SecureRandom.hex(4)}",
      image_url: "https://example.com/photo.jpg",
      short_description: "A short description",
      long_description: "A longer description " * 5,
      rating: 4
    }.merge(overrides)
  end

  describe "GET /api/v1/trips" do
    it "returns paginated trips with data and meta" do
      Trip.create!(valid_trip_attributes)

      get "/api/v1/trips"

      expect(response).to have_http_status(:ok)
      json = response.parsed_body
      expect(json).to include("data", "meta")
      expect(json["meta"]).to include(
        "current_page" => 1,
        "total_pages" => 1,
        "total_count" => 1,
        "per_page" => 10
      )
      expect(json["data"].first).to include(
        "id",
        "name",
        "image_url",
        "short_description",
        "rating"
      )
      expect(json["data"].first).not_to have_key("long_description")
    end

    it "respects pagination params" do
      3.times { |i| Trip.create!(valid_trip_attributes(name: "Page Trip #{i}")) }

      get "/api/v1/trips", params: { page: 1, per_page: 2 }

      json = response.parsed_body
      expect(json["data"].size).to eq(2)
      expect(json["meta"]["per_page"]).to eq(2)
      expect(json["meta"]["total_pages"]).to eq(2)
    end

    describe "filters trips" do
      it "by name" do
        Trip.create!(valid_trip_attributes(name: "Unique Park Alpha"))
        Trip.create!(valid_trip_attributes(name: "Other Place"))

        get "/api/v1/trips", params: { search: "Unique" }

        expect(response).to have_http_status(:ok)
        names = response.parsed_body["data"].map { |row| row["name"] }
        expect(names).to include("Unique Park Alpha")
        expect(names).not_to include("Other Place")
      end

      it "by min rating" do
        [3, 4, 5].each do |rating|
          Trip.create!(valid_trip_attributes(rating: rating))
        end

        get "/api/v1/trips", params: { min_rating: 4 }

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json["data"].size).to eq(2)
        expect(json["data"].map { |row| row["rating"] }).to all(be >= 4)
      end
    end

    describe "sorts trips" do
      it "by name by default" do
        ["B", "A", "C"].each do |name|
          Trip.create!(valid_trip_attributes(name: name))
        end

        get "/api/v1/trips", params: { sort: "name_asc" }

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json["data"].map { |row| row["name"] }).to eq(["A", "B", "C"])
      end

      it "by rating asc" do
        [3, 4, 5].each do |rating|
          Trip.create!(valid_trip_attributes(rating: rating))
        end

        get "/api/v1/trips", params: { sort: "rating_asc" }

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json["data"].map { |row| row["rating"] }).to eq([3, 4, 5])
      end

      it "by rating desc" do
        [3, 4, 5].each do |rating|
          Trip.create!(valid_trip_attributes(rating: rating))
        end

        get "/api/v1/trips", params: { sort: "rating_desc" }

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json["data"].map { |row| row["rating"] }).to eq([5, 4, 3])
      end
    end
  end

  describe "GET /api/v1/trips/:id" do
    it "returns the trip as JSON" do
      trip = Trip.create!(valid_trip_attributes)

      get "/api/v1/trips/#{trip.id}"

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body["id"]).to eq(trip.id)
      expect(body["name"]).to eq(trip.name)
      expect(body["image_url"]).to eq(trip.image_url)
      expect(body["short_description"]).to eq(trip.short_description)
      expect(body["long_description"]).to eq(trip.long_description)
      expect(body["rating"]).to eq(trip.rating)
    end

    it "returns 404 when the trip does not exist" do
      get "/api/v1/trips/999999"

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/trips" do
    it "creates a trip and returns 201" do
      attrs = valid_trip_attributes

      expect { post "/api/v1/trips", params: { trip: attrs }, as: :json }.to change(Trip, :count).by(1)

      expect(response).to have_http_status(:created)
      body = response.parsed_body
      expect(body["name"]).to eq(attrs[:name])
      expect(body["image_url"]).to eq(attrs[:image_url])
      expect(body["short_description"]).to eq(attrs[:short_description])
      expect(body["long_description"]).to eq(attrs[:long_description])
      expect(body["rating"]).to eq(attrs[:rating])
    end

    it "returns validation errors with 422" do
      post "/api/v1/trips",
           params: { trip: valid_trip_attributes(name: "", rating: 99, image_url: "not a url") },
           as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body).to include("errors")
      expect(response.parsed_body["errors"]).to include("name" => ["can't be blank"],
                                                        "rating" => ["must be between 1 and 5"],
                                                        "image_url" => ["is not a valid URL"])
    end
  end
end
