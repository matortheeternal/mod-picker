class NotificationsController < ApplicationController
  # GET /notifications/:page
  def index
    @notifications = current_user.notifications.paginate(:page => params[:page])
    count = current_user.notifications.count

    render :json => {
        notifications: @notifications,
        max_entries: count,
        entries_per_page: Notification.per_page
    }
  end

  # DELETE /notifications/:id
  def destroy
    @notification = current_user.notifications.find_by(event_id: params[:id])
    if @notification.destroy
      render json: {status: :ok}
    else
      render json: @notification.errors, status: :unprocessable_entity
    end
  end
end