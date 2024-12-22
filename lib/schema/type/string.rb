# frozen_string_literal: true

module Schema::Type::String
  extend self

  def build(options)
    lambda do |value|
      return [:error, :string] if !value.is_a?(::String)

      value = value.strip if options[:strip]

      if options.key?(:empty) && !validate_empty(value, options[:empty])
        return [:error, :empty]
      end

      if (minlength = options[:minlength]) && !validate_minlength(value, minlength)
        return [:error, [:minlength, minlength:]]
      end

      if (maxlength = options[:maxlength]) && !validate_maxlength(value, maxlength)
        return [:error, [:maxlength, maxlength:]]
      end

      if (format = options[:format]) && !validate_format(value, format)
        return [:error, [:format, format:]]
      end

      [:ok, value]
    end
  end

  private
    def validate_empty(value, allow_empty)
      return true if allow_empty

      !value.empty?
    end

    def validate_minlength(value, minlength)
      value.length >= minlength
    end

    def validate_maxlength(value, maxlength)
      value.length <= maxlength
    end

    def validate_format(value, format)
      format.match?(value)
    end
end
