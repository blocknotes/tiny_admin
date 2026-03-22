# frozen_string_literal: true

module TinyAdmin
  module Views
    module Pages
      class PageNotAllowed < ErrorPage
        def title
          "Page not allowed"
        end
      end
    end
  end
end
