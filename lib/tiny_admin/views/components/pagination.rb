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
                if pages <= 10
                  pages_range(1..pages)
                elsif current <= 4 || current >= pages - 3
                  pages_range(1..(current <= 4 ? current + 2 : 4), with_dots: true)
                  pages_range((current > pages - 4 ? current - 2 : pages - 2)..pages)
                else
                  pages_range(1..1, with_dots: true)
                  pages_range(current - 2..current + 2, with_dots: true)
                  pages_range(pages..pages)
                end
              }
            }
          }
        end

        private

        def pages_range(range, with_dots: false)
          range.each do |page|
            li(class: page == current ? 'page-item active' : 'page-item') {
              href = query_string.empty? ? "?p=#{page}" : "?#{query_string}&p=#{page}"
              a(class: 'page-link', href: href) { page }
            }
          end
          dots if with_dots
        end

        def dots
          li(class: 'page-item disabled') {
            a(class: 'page-link') { '...' }
          }
        end
      end
    end
  end
end
