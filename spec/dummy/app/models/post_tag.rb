# frozen_string_literal: true

class PostTag < ApplicationRecord
  belongs_to :post, inverse_of: :post_tags, optional: false
  belongs_to :tag,  inverse_of: :post_tags, optional: false
end
