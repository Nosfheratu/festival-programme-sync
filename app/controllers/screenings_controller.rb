class ScreeningsController < ApplicationController
  def index
    @venues = Venue.order(:name)

    @screenings = Screening.joins(:film).order(:starts_at)
    @screenings = @screenings.where("films.title LIKE ?", "%#{params[:q]}%") if params[:q].present?
    @screenings = @screenings.where(venue_id: params[:venue_id]) if params[:venue_id].present?

    if params[:date].present?
      date = begin
        Date.parse(params[:date])
      rescue ArgumentError
        nil
      end
      @screenings = @screenings.where(starts_at: date.all_day) if date
    end
  end
end
