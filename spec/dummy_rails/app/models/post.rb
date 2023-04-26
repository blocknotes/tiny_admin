# frozen_string_literal: true

# - Create a post:
# Post.create! title: 'A post', author: Author.first
# Post.last.tags << Tag.last
class Post < ApplicationRecord
  enum state: { available: 0, unavailable: 1, arriving: 2 }

  belongs_to :author, inverse_of: :posts, autosave: true
  # with autosave if you change an attribute using the association, calling a save on parent will propagate the changes

  has_one :author_profile, through: :author, source: :profile

  has_many :post_tags, inverse_of: :post, dependent: :destroy
  has_many :tags, through: :post_tags

  validates :title, allow_blank: false, presence: true

  scope :published, -> { where(published: true) }
  scope :recents, -> { where('created_at > ?', Date.current - 8.months) }

  # # override a field - can be dangerous
  # def title
  #   "<<<#{super}>>>"
  # end

  def short_title(**args)
    title.truncate(args[:count] || 10)
  end

  def upper_title
    title.upcase
  end

  def old_method
    ActiveRecord::Base.allow_unsafe_raw_sql = true
  end
end
