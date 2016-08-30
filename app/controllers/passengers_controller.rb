class PassengersController < ApplicationController

  before_action :find_journey, only: [:create, :update]

  def create
    @passenger = Passenger.new
    @passenger.user = current_user
    @passenger.journey = @journey
    @passenger.save
  end

  def update
    @passenger = Passenger.find(params[:id])
    @passenger.update(passenger_params)
    redirect_to journey_path(@journey)
  end

  private

  def find_journey
    @journey = Journey.find(params[:journey_id])
  end

  def passenger_params
    params.require(:passenger).permit(:driver_rating, :passenger_rating)
  end
end
