# frozen_string_literal: true

# - Create a profile:
# author.build_profile description: 'Just a desc'
# author.save
class Author < ApplicationRecord
  # has_many :posts do
  #   def filtered  # Association Extensions
  #     where('created_at < ?', Date.today)
  #   end
  # end

  has_many :posts, dependent: :nullify
  has_many :published_posts, -> { published }, class_name: 'Post', dependent: :nullify, inverse_of: :author
  has_many :recent_posts, -> { recents }, class_name: 'Post', dependent: :nullify, inverse_of: :author

  # has_many :posts,  inverse_of: :author, dependent: :nullify

  has_one :profile, inverse_of: :author, dependent: :destroy

  accepts_nested_attributes_for :profile, allow_destroy: true

  validates :email, format: { with: /\A[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\z/i, message: 'Invalid email' }

  validate -> {
    errors.add( :base, 'Invalid age' ) if !age || age.to_i % 3 == 1
  }

  # validate :custom

  def to_s
    "#{name} (#{age})"
  end
end
