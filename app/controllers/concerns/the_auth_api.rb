module TheAuthApi
  extend ActiveSupport::Concern
  include TheAuthCommon

  included do
    before_action :require_login_from_token, if: -> { !request.format.html? }
    after_action :set_auth_token
  end

  def require_login_from_token
    return if current_user || login_from_token

    render(json: { error: flash[:error] || 'no user!' }, status: 401)
  end

  def login_from_token
    return if request.headers['HTTP_AUTH_TOKEN'].blank?

    if verify_auth_token
      @access_token = AccessToken.find_by token: request.headers['HTTP_AUTH_TOKEN']
    end
    if @access_token
      @current_user ||= @access_token.user
    end
  end

  private
  def set_auth_token
    headers['Auth-Token'] = @current_user.get_access_token if @current_user
  end

  def verify_auth_token
    token = request.headers['Auth-Token']
    payload = decode_without_verification(token)

    return unless payload

    begin
      password_digest = User.find_by(id: payload['iss']).password_digest.to_s
      JWT.decode(token, password_digest, true, {'sub' => 'auth', verify_sub: true})
    rescue => e
      flash[:error] = e.message
    end
  end

  def decode_without_verification(token)
    begin
      payload, _ = JWT.decode(token, nil, false, verify_expiration: false)
    rescue => e
      flash[:error] = e.message
    end

    payload
  end

end