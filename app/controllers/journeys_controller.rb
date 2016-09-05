class JourneysController < ApplicationController
  before_action :set_journey, only:[:show, :edit, :update, :destroy, :on_journey, :seats_available, :driver]
  skip_before_action :authenticate_user!, only: [ :index, :show ]
  def index
    @journeys = policy_scope(Journey)
    @journeys.sort { |x,y| x.pick_up_time <=> y.pick_up_time }
  end

  def show
    @journey = Journey.find(params[:id])

    @hash = Gmaps4rails.build_markers([ @journey.pick_up_location, @journey.drop_off_location ]) do |location, marker|
      marker.lat location.latitude
      marker.lng location.longitude
    end
    on_journey?
    seats_available
  end

  def new
    @car = Car.find(params[:car_id])
    @journey = Journey.new
    @journey.car = @car
    @journey.build_pick_up_location
    @journey.build_drop_off_location
    authorize @journey
  end

  def create
    @car = Car.find(params[:car_id])
    @journey = @car.journeys.build(journey_params)
    @journey.user = current_user
    authorize @journey
    if @journey.save
      redirect_to journey_path(@journey)
    else
      render :new
    end
  end

  def edit
    @car = Car.find(params[:car_id])
    @journey.car = @car
    authorize @journey
  end

  def update
    @journey.update(journey_params)
    authorize @journey
    redirect_to journey_path(@journey)
  end

  def destroy
    @journey.destroy
    redirect_to journeys_path
  end

  def driver
    @user = current_user
    authorize @user
  end

  private

  def on_journey?
    @on_journey = false
    if  @journey.user == current_user || @journey.passengers.include?(current_user)
      @on_journey = true
    end
  end

  def seats_available
    @seats_available = @journey.seats_available - @journey.passengers.count
  end

  def set_journey
    @journey = Journey.find(params[:id])
    authorize @journey
  end

  def journey_params
    params.require(:journey).permit(
      :seats_available,
      :pick_up_time,
      pick_up_location_attributes: [ :address ],
      drop_off_location_attributes: [ :address ]
    )
  end
end
