# frozen_string_literal: true

class Explicit::Spec
  attr_accessor :description, :default, :nilable

  def self.build(spec)
    case spec
    in :agreement
      Explicit::Spec::Agreement.build({})
    in [:agreement, options]
      Explicit::Spec::Agreement.build(options)

    in [:array, itemspec]
      Explicit::Spec::Array.build(itemspec, {})
    in [:array, itemspec, options]
      Explicit::Spec::Array.build(itemspec, options)

    in :bigdecimal
      Explicit::Spec::Bigdecimal.build({})
    in [:bigdecimal, options]
      Explicit::Spec::Bigdecimal.build(options)

    in :boolean
      Explicit::Spec::Boolean.build({})
    in [:boolean, options]
      Explicit::Spec::Boolean.build(options)

    in :date_time_iso8601
      Explicit::Spec::DateTimeISO8601
    in :date_time_posix
      Explicit::Spec::DateTimePosix

    in [:default, defaultval, subspec]
      Explicit::Spec::Default.build(defaultval, subspec)

    in [:description, _, subspec]
      Explicit::Spec.build(subspec)

    in [:hash, keyspec, valuespec]
      Explicit::Spec::Hash.build(keyspec, valuespec, {})
    in [:hash, keyspec, valuespec, options]
      Explicit::Spec::Hash.build(keyspec, valuespec, options)

    in [:inclusion, options]
      Explicit::Spec::Inclusion.build(options)

    in :integer
      Explicit::Spec::Integer.new
    in [:integer, options]
      Explicit::Spec::Integer.new(**options)

    in [:literal, value]
      Explicit::Spec::Literal.new(value:)
    in ::String
      Explicit::Spec::Literal.new(value: spec)

    in [:nilable, spec]
      Explicit::Spec::Nilable.apply(spec)

    in [:one_of, *subspecs]
      Explicit::Spec::OneOf.new(subspecs:)

    in ::Hash
      Explicit::Spec::Record.new(attributes: spec)

    in :string
      Explicit::Spec::String.new
    in [:string, options]
      Explicit::Spec::String.new(**options)
    end
  end
end