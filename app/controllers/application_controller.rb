class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_user, :logged_in?

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  def current_user
    return @current_user if defined?(@current_user)
    if session[:user_id]
      @current_user = User.find_by(id: session[:user_id])
    else
      @current_user = nil
    end
  end

  def logged_in?
    current_user.present?
  end

  def require_login
    unless logged_in?
      redirect_to login_path, alert: 'Please log in to continue'
    end
  end

  def record_not_found(exception = nil)
    logger.info "Record not found: #{exception&.message}"
    redirect_to posts_path, alert: 'The requested item was not found.'
  end
end
