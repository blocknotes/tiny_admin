class AdminHelper < TinyAdmin::Support
  class << self
    def multiline(array, options: [])
      raw_html array.join("<br/>")
    end
  end
end
