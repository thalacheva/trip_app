module Api::V1
  class TripsController < ApplicationController
    def index
      @trips = Trip.search_by_name(params[:search])
        .with_min_rating(params[:min_rating])
        .order_by(params[:sort])
        .page(params[:page])
        .per(params[:per_page] || 10)
        .select(:id, :name, :image_url, :short_description, :rating)

      render json: {
        data: @trips.as_json(only: [:id, :name, :image_url, :short_description, :rating]),
        meta: {
          current_page: @trips.current_page,
          total_pages: @trips.total_pages,
          total_count: @trips.total_count,
          per_page: @trips.limit_value
        }
      }, status: :ok
    end

    def show
      @trip = Trip.find(params[:id])

      render json: @trip, serializer: TripSerializer, status: :ok
    end

    def create
      @trip = Trip.new(trip_params)

      if @trip.save
        render json: @trip, serializer: TripSerializer, status: :created
      else
        render json: { errors: @trip.errors.as_json }, status: :unprocessable_content
      end
    end

    private

    def trip_params
      params.require(:trip).permit(:name, :image_url, :short_description, :long_description, :rating)
    end
  end
end

