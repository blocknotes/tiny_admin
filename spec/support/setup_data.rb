# frozen_string_literal: true

RSpec.shared_context 'with some data' do
  def setup_data(posts_count: 5)
    # Authors
    authors = Array.new(3) do
      author_ref = Author.count + 1
      Author.create!(name: "An author #{author_ref}", age: 24 + (author_ref * 3), email: "aaa#{author_ref}@bbb.ccc")
    end

    # Posts
    posts_count.times do |i|
      post_ref = Post.count + 1
      Post.create!(author: authors[i % 3], title: "A post #{post_ref + i}", description: 'Some post content')
    end
  end
end
