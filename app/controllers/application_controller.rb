class ApplicationController < ActionController::Base

  allow_browser versions: :modern

  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  helper_method :reply_to

  def reply_to(message)
    if message.sender == current_user.address && message.receivers == [current_user.address]
      return message.receivers 
    end
  
    (message.receivers + [message.sender] - [current_user.address]).uniq
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:handle])
  end

  def after_sign_in_path_for(resource)
    conversations_path
  end

end