# frozen_string_literal: true

module TinyAdmin
  class RawHtml
    attr_reader :to_s

    def initialize(value)
      @to_s = value.to_s
    end
  end
end
