class User < ApplicationRecord
  has_secure_password
  USER_PERMIT = %i(name email password password_confirmation birthday
gender).freeze
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :name, presence: true,
length: {maximum: Settings.development.user.MAX_NAME_LENGTH}
  validates :email, presence: true,
length: {maximum: Settings.development.user.MAX_EMAIL_LENGTH},
format: {with: VALID_EMAIL_REGEX}, uniqueness: {case_sensitive: false}
  validates :birthday, presence: true
  validate :birthday_within_100_years
  validates :gender, presence: true

  private
  def birthday_within_100_years
    return if birthday.blank? || !birthday.is_a?(Date)

    current_date = Time.zone.today
    hundred_years_ago = current_date.prev_year(Settings.development
    .user.BIRTHDAY_YEAR_LIMIT)

    if birthday > current_date
      errors.add(:birthday, :cannot_be_in_the_future)
    elsif birthday < hundred_years_ago
      errors.add(:birthday, :must_be_within_100_years)
    end
  end
end
