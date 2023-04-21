# frozen_string_literal: true

module TinyAdmin
  module Views
    module Components
      class Head < BasicComponent
        attr_accessor :extra_styles, :page_title, :style_links

        def template
          head {
            meta charset: 'utf-8'
            meta name: 'viewport', content: 'width=device-width, initial-scale=1'
            title {
              page_title
            }
            style_links.each do |style_link|
              link(**style_link)
            end
            style { extra_styles } if extra_styles
          }
        end
      end
    end
  end
end
