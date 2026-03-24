module Api::V1
  class TripsController < ApplicationController
    def index
      @trips = Trip.all

      render json: @trips, status: :ok
    end

    def show
      @trip = Trip.find(params[:id])

      render json: @trip, status: :ok
    end

    def create
      @trip = Trip.new(trip_params)

      if @trip.save
        render json: @trip, status: :created
      else
        render json: @trip.errors, status: :unprocessable_entity
      end
    end

    private

    def trip_params
      params.require(:trip).permit(:name, :image_url, :short_description, :long_description, :rating)
    end
  end
end

