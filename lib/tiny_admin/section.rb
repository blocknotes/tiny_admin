# frozen_string_literal: true

module TinyAdmin
  Section = Struct.new(
    :name,
    :path,
    :options,
    keyword_init: true
  )
end
