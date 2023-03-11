# frozen_string_literal: true

RSpec.shared_context 'with some data' do
  def setup_data
    5.times do
      # Authors
      author_ref = Author.count + 1
      author = Author.create!(name: "An author #{author_ref}", age: 24 + (author_ref * 3), email: "aaa#{author_ref}@bbb.ccc")

      # Posts
      post_ref = Post.count + 1
      5.times do |i|
        Post.create!(author: author, title: "A post #{post_ref + i}", description: 'Some post content')
      end
    end
  end
end
