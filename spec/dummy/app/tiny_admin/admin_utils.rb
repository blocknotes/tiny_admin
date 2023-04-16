module AdminUtils
  module_function

  def datetime_formatter(value, options: [])
    value&.to_date&.to_s
  end
end
