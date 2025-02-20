# frozen_string_literal: true

class Explicit::Type
  module Modifiers; end

  def self.build(type)
    case type
    in :agreement
      Explicit::Type::Agreement.new

    in [:array, item_type]
      Explicit::Type::Array.new(item_type:)
    in [:array, item_type, options]
      Explicit::Type::Array.new(item_type:, **options)

    in :big_decimal
      Explicit::Type::BigDecimal.new
    in [:big_decimal, options]
      Explicit::Type::BigDecimal.new(**options)

    in :boolean
      Explicit::Type::Boolean.new

    in :date_range
      Explicit::Type::DateRange.new
    in [:date_range, options]
      Explicit::Type::DateRange.new(**options)

    in :date_time_iso8601_range
      Explicit::Type::DateTimeISO8601Range.new()
    in [:date_time_iso8601_range, options]
      Explicit::Type::DateTimeISO8601Range.new(**options)

    in :date_time_iso8601
      Explicit::Type::DateTimeISO8601.new
    in [:date_time_iso8601, options]
      Explicit::Type::DateTimeISO8601.new(**options)

    in :date_time_unix_epoch
      Explicit::Type::DateTimeUnixEpoch.new
    in [:date_time_unix_epoch, options]
      Explicit::Type::DateTimeUnixEpoch.new(**options)

    in :date
      Explicit::Type::Date.new
    in [:date, options]
      Explicit::Type::Date.new(**options)

    in [:hash, key_type, value_type]
      Explicit::Type::Hash.new(key_type:, value_type:)
    in [:hash, key_type, value_type, options]
      Explicit::Type::Hash.new(key_type:, value_type:, **options)

    in [:enum, allowed_values]
      Explicit::Type::Enum.new(allowed_values)

    in :file
      Explicit::Type::File.new
    in [:file, options]
      Explicit::Type::File.new(**options)

    in :integer
      Explicit::Type::Integer.new
    in [:integer, options]
      Explicit::Type::Integer.new(**options)

    in [:literal, value]
      Explicit::Type::Literal.new(value:)
    in ::String
      Explicit::Type::Literal.new(value: type)

    in [:one_of, *subtypes]
      Explicit::Type::OneOf.new(subtypes:)

    in ::Hash
      Explicit::Type::Record.new(attributes: type)

    in :string
      Explicit::Type::String.new
    in [:string, options]
      Explicit::Type::String.new(**options)

    ## MODIFIERS

    in [:default, default, subtype]
      Explicit::Type::Modifiers::Default.apply(default, subtype)

    in [:description, description, subtype]
      Explicit::Type::Modifiers::Description.apply(description, subtype)

    in [:nilable, type]
      Explicit::Type::Modifiers::Nilable.apply(type)

    in [:_param_location, param_location, type]
      Explicit::Type::Modifiers::ParamLocation.apply(param_location, type)
    end
  end

  attr_accessor :description, :default, :nilable, :param_location

  def param_location_path?
    param_location == :path
  end

  def required?
    !nilable
  end

  def error_i18n(name, context = {})
    key = "explicit.errors.#{name}"

    translation =
      if ::I18n.exists?(key)
        ::I18n.t(key, **context)
      else
        ::I18n.t(key, **context.merge(locale: :en))
      end

    [ :error, translation ]
  end

  def swagger_i18n(name, context = {})
    key = "explicit.swagger.#{name}"

    if ::I18n.exists?(key)
      ::I18n.t(key, **context)
    else
      ::I18n.t(key, **context.merge(locale: :en))
    end
  end

  def merge_base_swagger_schema(attributes)
    topics = attributes.delete(:description_topics)&.compact_blank || []

    formatted_description =
      if description.present? && topics.empty?
        description
      elsif description.present? && topics.any?
        description + "\n\n" + topics.join("\n")
      else
        topics.join("\n")
      end

    default_value =
      if default&.respond_to?(:call)
        nil
      else
        default
      end

    base_attributes = {
      default: default_value,
      description: formatted_description
    }

    base_attributes.merge(attributes).compact_blank
  end
end
