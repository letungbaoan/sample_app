class Micropost < ApplicationRecord
  MAX_IMAGE_SIZE = 5.megabytes
  MICROPOST_PERMIT = %i(content image).freeze
  MEGABYTE_IN_BYTES = 1.megabyte.freeze
  IMAGE_DISPLAY_SIZE = [500, 500].freeze

  belongs_to :user
  has_one_attached :image

  scope :newest, -> {order(created_at: :desc)}
  scope :relate_post, ->(user_ids) {where user_id: user_ids}

  validates :content, presence: true,
                      length: {maximum: Settings.development.digits.DIGIT_140}

  validates :image,
            content_type: {in: %w(image/jpeg image/gif image/png),
                           message: :invalid_image_format},
            size: {less_than: MAX_IMAGE_SIZE,
                   message: :image_size_too_large}

  has_one_attached :image do |attachable|
    attachable.variant :display, resize_to_limit: IMAGE_DISPLAY_SIZE
  end
end
