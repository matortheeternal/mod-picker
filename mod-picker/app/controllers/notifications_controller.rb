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

  # GET /notifications/recent
  def recent
    @notifications = current_user.recent_notifications
    render :json => @notifications
  end

  # POST /notifications/read
  def read
    current_user.notifications.where(id: params[:ids]).update_all(read: true)
    render :json => current_user.recent_notifications
  end
end