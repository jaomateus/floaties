class FloatiesController < ApplicationController
  def index
    # @floaties = Floaty.all
    @floaties = Floaty.geocoded
    if params[:query].present?
      sql_query = "title ILIKE :query OR category ILIKE :query OR address ILIKE :query"
      @floaties = Floaty.geocoded.where(sql_query, query: "%#{params[:query]}%")
    else
      @floaties = Floaty.geocoded
    end
    # The `geocoded` scope filters only flats with coordinates
    @markers = @floaties.map do |floaty|
      {
        lat: floaty.latitude,
        lng: floaty.longitude,
        info_window: render_to_string(partial: "info_window", locals: { floaty: floaty }),
        # image_url: helpers.asset_url("quaqua.png")
      }
    end
  end

  def show
    @floaty = Floaty.find(params[:id])
    @review = Review.new
    @markers = [{
      lat: @floaty.latitude,
      lng: @floaty.longitude,
      info_window: render_to_string(partial: "info_window", locals: { floaty: @floaty })
      # image_url: helpers.asset_url("quaqua.png")
    }]
  end

  def new
    @floaty = Floaty.new
  end

  def create
    @floaty = Floaty.new(floaty_params)
    @floaty.user = current_user
    if @floaty.save
      redirect_to floaty_path(@floaty)
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def floaty_params
    params.require(:floaty).permit(:title, :category, :details, :price, :city, :address, photos: [])
  end
end
