class LatestAuthorsWidget < TinyAdmin::Views::BasicWidget
  def template
    h2 { 'Latest authors' }

    ul {
      Author.last(3).each do |author|
        li { author.to_s }
      end
    }
  end
end
