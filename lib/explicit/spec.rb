# frozen_string_literal: true

class Explicit::Spec
  module Modifiers; end

  attr_accessor :description, :default, :nilable

  def self.build(spec)
    case spec
    in :agreement
      Explicit::Spec::Agreement.new
    in [:agreement, options]
      Explicit::Spec::Agreement.new(**options)

    in [:array, itemspec]
      Explicit::Spec::Array.new(itemspec:)
    in [:array, itemspec, options]
      Explicit::Spec::Array.new(itemspec:, **options)

    in :bigdecimal
      Explicit::Spec::BigDecimal.new
    in [:bigdecimal, options]
      Explicit::Spec::BigDecimal.new(**options)

    in :boolean
      Explicit::Spec::Boolean.new
    in [:boolean, options]
      Explicit::Spec::Boolean.new(**options)

    in :date_time_iso8601
      Explicit::Spec::DateTimeISO8601.new
    in :date_time_posix
      Explicit::Spec::DateTimePosix.new

    in [:hash, keyspec, valuespec]
      Explicit::Spec::Hash.new(keyspec:, valuespec:)
    in [:hash, keyspec, valuespec, options]
      Explicit::Spec::Hash.new(keyspec:, valuespec:, **options)

    in [:enum, allowed_values]
      Explicit::Spec::Enum.new(allowed_values)

    in :integer
      Explicit::Spec::Integer.new
    in [:integer, options]
      Explicit::Spec::Integer.new(**options)

    in [:literal, value]
      Explicit::Spec::Literal.new(value:)
    in ::String
      Explicit::Spec::Literal.new(value: spec)

    in [:one_of, *subspecs]
      Explicit::Spec::OneOf.new(subspecs:)

    in ::Hash
      Explicit::Spec::Record.new(attributes: spec)

    in :string
      Explicit::Spec::String.new
    in [:string, options]
      Explicit::Spec::String.new(**options)

    ## MODIFIERS

    in [:default, default, subspec]
      Explicit::Spec::Modifiers::Default.apply(default, subspec)

    in [:description, description, subspec]
      Explicit::Spec::Modifiers::Description.apply(description, subspec)

    in [:nilable, spec]
      Explicit::Spec::Modifiers::Nilable.apply(spec)
    end
  end

  def error_i18n(name, context = {})
    key = "explicit.errors.#{name}"

    ::I18n.t(key, **context)
  end
end