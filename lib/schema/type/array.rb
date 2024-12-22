# frozen_string_literal: true

module Schema::Type::Array
  extend self

  def build(schema, options)
    subschema = Schema::Type::Builder.build(schema)

    lambda do |values|
      return [:error, :array] if !values.is_a?(::Array)

      if options[:empty] == false && values.empty?
        return [:error, :empty]
      end

      validated = []

      values.each.with_index do |value, index|
        case subschema.call(value)
        in [:ok, value]  then validated << value
        in [:error, err] then return [:error, [:array, index, err]]
        end
      end

      [:ok, validated]
    end
  end
end
