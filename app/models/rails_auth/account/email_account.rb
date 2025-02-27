module RailsAuth::Account::EmailAccount
  extend ActiveSupport::Concern
  included do
    has_one :check_token, -> { valid }, class_name: 'EmailToken', foreign_key: :account_id
    has_many :check_tokens, class_name: 'EmailToken', foreign_key: :account_id, dependent: :delete_all
  end
  
  def reset_notice
    UserMailer.password_reset(self.id).deliver_later
  end
  
end
