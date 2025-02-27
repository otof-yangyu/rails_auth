# Deal with token
#
# 用于处理Token
module RailsAuth::VerifyToken
  extend ActiveSupport::Concern

  included do
    belongs_to :account
    belongs_to :user, optional: true

    scope :valid, -> { where('expire_at >= ?', Time.now).order(access_counter: :asc) }
    validates :token, presence: true
    after_initialize :update_token, if: -> { new_record? }
  end

  def update_token
    self.token = SecureRandom.uuid
    self.expire_at = 14.days.since
    self
  end

  def verify_token?(now = Time.now)
    return false if self.expire_at.blank?
    if now > self.expire_at
      self.errors.add(:token, 'The token has expired')
      return false
    end

    true
  end

  def send_out
    raise 'should implement in subclass'
  end

  def self.create_with_account(identity)
    verify_token = self.valid.find_by(identity: identity)
    return verify_token if verify_token
    verify_token = self.new(identity: identity)
    self.transaction do
      self.where(identity: identity).delete_all
      verify_token.save!
    end
    verify_token
  end

end
