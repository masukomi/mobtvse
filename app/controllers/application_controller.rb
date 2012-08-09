class ApplicationController < ActionController::Base
  protect_from_forgery

  def s3_enabled?
    if CONFIG.has_key?('s3') and CONFIG['s3'].has_key?('enabled')
      if CONFIG['s3']['image_bucket_name'] and CONFIG['s3']['access_key_id'] and CONFIG['s3']['secret_access_key']
        return CONFIG['s3']['enabled']
      end
    end
    return false
  end


  private

  def authenticate
    authenticate_or_request_with_http_basic do |login, password|
      if login == CONFIG['login'] and password == CONFIG['password']
      	session[:admin] = true
      	true
      end
    end
  end
end
