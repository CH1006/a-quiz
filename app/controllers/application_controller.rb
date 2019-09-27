# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  add_flash_types :success, :danger, :warning, :info

  rescue_from ActionController::RoutingError do
    render file: "#{Rails.root}/public/404", layout: false, status: :not_found
  end

  def after_sign_in_path_for(resource)
    link = resource.admin? ? admin_dashboard_path : root_path
    stored_location_for(resource) || link
  end

  private

  def limit_access
    return if user_signed_in? && current_user.admin?

    flash[:danger] = t "application.danger"
    redirect_to root_path
  end
end
