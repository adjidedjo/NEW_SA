class Api::SessionsController < DeviseController
  prepend_before_action :require_no_authentication, :only => [:create ]
  skip_before_action :verify_authenticity_token

  before_action :ensure_params_exist

  respond_to :json
  def create
    # build_resource
    resource = User.find_for_database_authentication(:username=>params[:user][:username])
    return invalid_login_attempt unless resource

    if resource.valid_password?(params[:user][:password])
      sign_in("user", resource)
      render :json=> {:success=>true, :auth_token=>resource.auth_token, :login=>resource.username, :email=>resource.email}
    return
    end
    invalid_login_attempt
  end

  def destroy
    sign_out(resource_name)
  end

  protected
  
  def ensure_authentication_token
    raise self.inspect
    if self.auth_token.blank?
      self.auth_token = generate_authentication_token
    end
  end

  def ensure_params_exist
    return unless params[:user].blank?
    render :json=>{:success=>false, :message=>"missing user_login parameter"}, :status=>422
  end

  def invalid_login_attempt
    warden.custom_failure!
    render :json=> {:success=>false, :message=>"Error with your login or password"}, :status=>401
  end
  
  private
  
  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(auth_token: token).first
    end
  end
end