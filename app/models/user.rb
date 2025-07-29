class User < ApplicationRecord
  has_secure_password

  DEFAULT_INCLUDES_FOR_FEED = [:user, {image_attachment: :blob}].freeze
  USER_PERMIT = %i(name email password password_confirmation birthday
gender).freeze
  PASSWORD_RESET_PERMIT = %i(password password_confirmation).freeze
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  PASSWORD_RESET_EXPIRATION_TIME = 2.hours

  enum gender: {male: 0, female: 1, other: 2}

  attr_accessor :remember_token, :activation_token, :reset_token

  has_many :microposts, dependent: :destroy
  has_many :active_relationships, class_name: Relationship.name,
foreign_key: :follower_id, dependent: :destroy
  has_many :passive_relationships, class_name: Relationship.name,
foreign_key: :followed_id, dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower

  before_save :downcase_email
  before_create :create_activation_digest

  scope :recent, -> {order(created_at: :desc)}
  scope :relate_post, ->(user_ids) {where user_id: user_ids}

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

  def activate
    update_columns activated: true, activated_at: Time.zone.now
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_columns reset_digest: User.digest(reset_token),
                   reset_sent_at: Time.zone.now
  end

  def feed
    Micropost.relate_post(following_ids << id)
             .includes(DEFAULT_INCLUDES_FOR_FEED)
  end

  def follow other_user
    following << other_user
  end

  def unfollow other_user
    following.delete(other_user)
  end

  def following? other_user
    following.include?(other_user)
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def remember
    self.remember_token = User.new_token
    update_column :remember_digest, User.digest(remember_token)
  end

  def authenticated? attribute, token
    digest = send "#{attribute}_digest"
    return false unless digest

    begin
      BCrypt::Password.new(digest).is_password?(token)
    rescue BCrypt::Errors::InvalidHash
      false
    end
  end

  def forget
    update_column :remember_digest, nil
  end

  def password_reset_expired?
    reset_sent_at < PASSWORD_RESET_EXPIRATION_TIME.ago
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

  def downcase_email
    email.downcase!
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
