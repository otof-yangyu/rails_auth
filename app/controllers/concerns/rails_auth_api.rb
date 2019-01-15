require 'jwt'
module RailsAuthApi

  def require_login_from_token
    return if login_from_token

    raise ActionController::UnauthorizedError
  end

  def login_from_token
    return if request.headers['Auth-Token'].blank?

    if verify_auth_token
      @access_token = AccessToken.find_by token: request.headers['Auth-Token']
    end
    if @access_token
      @current_user ||= @access_token.user
    end
  end

  def login_as(user)
    user.update(last_login_at: Time.now)
    @current_user = user
  end

  private
  def set_auth_token
    if api_request?
      headers['Auth-Token'] = @current_user.auth_token if @current_user
    end
  end

  def verify_auth_token
    token = request.headers['Auth-Token']
    payload = JwtHelper.decode_without_verification(token)

    return unless payload

    begin
      password_digest = User.find_by(id: payload['iss']).password_digest.to_s
      JWT.decode(token, password_digest, true, 'sub' => 'auth', verify_sub: true, verify_expiration: false)
    rescue => e
      puts nil, e.full_message(highlight: true, order: :top)
    end
  end

end
