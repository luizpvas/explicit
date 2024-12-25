# frozen_string_literal: true

module Explicit::Spec
  extend self

  def build(spec)
    case spec
    in :agreement
      Explicit::Spec::Agreement.build({})
    in [:agreement, options]
      Explicit::Spec::Agreement.build(options)

    in [:array, itemspec]
      Explicit::Spec::Array.build(itemspec, {})
    in [:array, itemspec, options]
      Explicit::Spec::Array.build(itemspec, options)

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

    in [:hash, keyspec, valuespec]
      Explicit::Spec::Hash.build(keyspec, valuespec, {})
    in [:hash, keyspec, valuespec, options]
      Explicit::Spec::Hash.build(keyspec, valuespec, options)

    in [:inclusion, options]
      Explicit::Spec::Inclusion.build(options)

    in :integer
      Explicit::Spec::Integer.build({})
    in [:integer, options]
      Explicit::Spec::Integer.build(options)

    in [:literal, value]
      Explicit::Spec::Literal.build(value)
    in ::String
      Explicit::Spec::Literal.build(spec)

    in [:nilable, options]
      Explicit::Spec::Nilable.build(options)

    in [:one_of, *subspecs]
      Explicit::Spec::OneOf.build(subspecs)

    in :string
      Explicit::Spec::String.build({})
    in [:string, options]
      Explicit::Spec::String.build(options)

    in ::Hash
      Explicit::Spec::Record.build(spec)
    end
  end
end