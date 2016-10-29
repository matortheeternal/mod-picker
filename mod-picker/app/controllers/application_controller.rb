class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Render 401 or 403 as appropriate

  rescue_from ::StandardError do |exception|
    error_hash = { error: exception.message }
    error_hash[:backtrace] = exception.backtrace unless Rails.env.production?
    render json: error_hash, status: 500
  end

  rescue_from CanCan::AccessDenied do |exception|
    if exception.message != "You are not authorized to access this page."
      render json: {error: exception.message}, status: 403
    elsif current_user
      render json: {error: "You are not authorized to access this resource."}, status: 403
    else
      render json: {error: "You must be logged in to perform this action."}, status: 401
    end
  end

  rescue_from Exceptions::ModExistsError do |exception|
    render json: exception.response_object, status: 500
  end

  def after_sign_in_path_for(resource)
    '/skyrim'
  end

  def check_sign_in
    unless current_user.present?
      render json: { error: "You must be logged in to perform this action." }, status: 401
    end
  end

  def json_format(resource, format=nil)
    format ||= action_name.to_sym
    resource.as_json(format: format)
  end

  def respond_with_json(resource, format=nil, root=nil)
    format ||= action_name.to_sym
    resource_json = resource.as_json(format: format)
    render json: root ? { root => resource_json } : resource_json
  end

  protected
    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:invitation_token, :username, :email, :password, :password_confirmation, :remember_me) }
      devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :username, :email, :password, :remember_me) }
      devise_parameter_sanitizer.for(:accept_invitation) { |u| u.permit(:username, :email, :password, :remember_me) }
      devise_parameter_sanitizer.for(:invite) { |u| u.permit(:invitation_token, :username, :email, :password, :remember_me) }
      devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :email, :password, :password_confirmation, :current_password) }
    end
end
