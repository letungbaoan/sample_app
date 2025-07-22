class User < ApplicationRecord
  has_secure_password
  USER_PERMIT = %i(name email password password_confirmation birthday
gender).freeze
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  attr_accessor :remember_token

  enum gender: {male: 0, female: 1, other: 2}

  scope :recent, ->{order(created_at: :desc)}

  validates :name, presence: true,
length: {maximum: Settings.development.user.MAX_NAME_LENGTH}
  validates :email, presence: true,
length: {maximum: Settings.development.user.MAX_EMAIL_LENGTH},
format: {with: VALID_EMAIL_REGEX}, uniqueness: {case_sensitive: false}
  validates :birthday, presence: true
  validate :birthday_within_100_years
  validates :gender, presence: true
  validates :gender, inclusion: {in: genders.keys}, allow_blank: true
  validates :password, presence: true,
length: {minimum: Settings.development.digits.DIGIT_6}, allow_nil: true

  def self.digest string
    cost = if ActiveModel::SecurePassword.min_cost
             BCrypt::Engine::MIN_COST
           else
             BCrypt::Engine.cost
           end
    BCrypt::Password.create string, cost:
  end

  class << self
    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    self.remember_token = User.new_token
    update_column :remember_digest, User.digest(remember_token)
  end

  def authenticated? remember_token
    return false if remember_digest.nil?

    begin
      BCrypt::Password.new(remember_digest).is_password?(remember_token)
    rescue BCrypt::Errors::InvalidHash
      false
    end
  end

  def forget
    update_column :remember_digest, nil
  end

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
