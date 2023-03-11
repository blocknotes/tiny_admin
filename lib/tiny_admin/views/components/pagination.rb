# frozen_string_literal: true

module TinyAdmin
  module Views
    module Components
      class Pagination < Phlex::HTML
        attr_reader :current, :pages, :query_string

        def initialize(current:, pages:, query_string:)
          @current = current
          @pages = pages
          @query_string = query_string
        end

        def template
          div(class: 'pagination-div') {
            nav('aria-label' => 'Pagination') {
              ul(class: 'pagination justify-content-center') {
                1.upto(pages) do |i|
                  li_class = (i == current ? 'page-item active' : 'page-item')
                  li(class: li_class) {
                    href = query_string.empty? ? "?p=#{i}" : "?#{query_string}&p=#{i}"
                    a(class: 'page-link', href: href) { i }
                  }
                end
              }
            }
          }
        end
      end
    end
  end
end
