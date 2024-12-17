# frozen_string_literal: true

module Schema::Type::Array
  extend self

  def build(spec, options)
    subspec = Schema::Type::Composer.compose(spec)

    lambda do |values|
      return [:error, :array] if !values.is_a?(::Array)

      if options[:empty] == false && values.empty?
        return [:error, :empty]
      end

      validated = []

      values.each do |value|
        case subspec.call(value)
        in [:ok, value]  then validated << value
        in [:error, err] then return [:error, [:array, err]]
        end
      end

      [:ok, validated]
    end
  end
end
