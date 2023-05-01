class LatestPostsWidget < TinyAdmin::Views::BasicWidget
  def template
    h2 { 'Latest posts' }

    ul {
      Post.last(3).each do |post|
        li { post.to_s }
      end
    }
  end
end
