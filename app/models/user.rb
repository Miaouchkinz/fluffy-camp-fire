class User < ApplicationRecord

  has_secure_password

  before_create :confirmation_token

  validates :first_name, :last_name,
              presence: true
  validates :password,
              presence: true, length: { minimum: 8 }
  validates :email,
              presence: true, uniqueness: true
  before_validation :downcase_and_strip_email

  def self.authenticate_with_credentials(email, password)
    email.strip!
    email.downcase!

    @user = User.find_by_email(email)
    @user ? @user.authenticate(password) : false
  end

  def email_activate
    self.email_confirmed = true
    self.confirm_token = nil
    save!(validate: false)
  end

  private

  def downcase_and_strip_email
    if self.email.present?
      self.email.downcase!
      self.email.strip!
    end
  end

  def confirmation_token
      if self.confirm_token.blank?
          self.confirm_token = SecureRandom.urlsafe_base64.to_s
      end
    end
end
