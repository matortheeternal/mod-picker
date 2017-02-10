class EventsController < ApplicationController
  # POST /events
  def index
    authorize! :index, Event
    @events = Event.paginate(page: params[:page]).order(:id => :DESC)
    count = Event.count

    render json: {
        events: @events,
        max_entries: count,
        entries_per_page: Event.per_page
    }
  end
end