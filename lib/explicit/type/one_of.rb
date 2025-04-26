# frozen_string_literal: true

class Explicit::Type::OneOf < Explicit::Type
  attr_reader :subtypes

  def initialize(subtypes:)
    @subtypes = subtypes.map { Explicit::Type.build(_1) }
    @subtypes_are_records = @subtypes.all? { _1.is_a?(Explicit::Type::Record) }
    @literal_attribute_name_shared_by_all_subtypes = nil

    if @subtypes_are_records
      literal_types = @subtypes.map do |subtype|
        subtype.attributes.find { |name, type| type.is_a?(Explicit::Type::Literal) }
      end

      literal_names = literal_types.map { |name, _| name }.uniq

      if literal_types.all?(&:present?) && literal_names.one?
        @literal_attribute_name_shared_by_all_subtypes = literal_names.first
      end
    end
  end

  def validate(value)
    errors = []

    @subtypes.each do |subtype|
      case subtype.validate(value)
      in [:ok, validated_value]
        return [ :ok, validated_value ]
      in [:error, err]
        errors << err
      end
    end

    if (err = guess_error_for_intended_subtype_via_matching_literal(value:, errors:))
      return [ :error, err ]
    end

    if (err = guess_error_for_intended_subtype_via_matching_keys(value:, errors:))
      return [ :error, err ]
    end

    separator =
      if ::I18n.exists?("explicit.errors.one_of_separator")
        ::I18n.t("explicit.errors.one_of_separator")
      else
        ::I18n.t("explicit.errors.one_of_separator", locale: :en)
      end

    error =
      if @subtypes_are_records
        errors.map { ::JSON.pretty_generate(_1) }.join("\n\n#{separator}\n\n")
      else
        errors.join(" #{separator} ")
      end

    [ :error, error ]
  end

  def guess_error_for_intended_subtype_via_matching_literal(value:, errors:)
    return nil if !@literal_attribute_name_shared_by_all_subtypes
    return nil if !value.is_a?(::Hash)

    errors.find do |error|
      !error.key?(@literal_attribute_name_shared_by_all_subtypes)
    end
  end

  def guess_error_for_intended_subtype_via_matching_keys(value:, errors:)
    return nil if !@subtypes_are_records
    return nil if !value.is_a?(::Hash)

    matches = @subtypes.zip(errors).filter_map do |(subtype, error)|
      s1 = Set.new(subtype.attributes.keys)
      s2 = Set.new(value.keys)

      if s1.intersection(s2).size.positive?
        { subtype:, error: }
      else
        nil
      end
    end

    return matches.first[:error] if matches.one?

    nil
  end

  concerning :Webpage do
    def summary
      @subtypes.all? { _1.is_a?(Explicit::Type::Record) } ? "object" : "any"
    end

    def partial
      "explicit/documentation/type/one_of"
    end

    def has_details?
      true
    end
  end

  def json_schema(flavour)
    raise ::NotImplementedError if flavour == :mcp

    { oneOf: subtypes.map(&:swagger_schema) }
  end
end
