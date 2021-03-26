class ApplicationController < ActionController::Base
  check_authorization unless: :devise_controller?

  rescue_from CanCan::AccessDenied do |exception|
    render file: Rails.root.join('public', '403.html'), status: :forbidden
  end
end
