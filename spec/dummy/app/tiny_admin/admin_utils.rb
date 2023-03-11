module AdminUtils
  module_function

  def datetime_formatter(value)
    value&.to_date&.to_s
  end
end
