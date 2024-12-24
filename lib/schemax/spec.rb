# frozen_string_literal: true

module Schemax::Spec
  extend self

  def build(spec)
    case spec
    in :agreement
      Schemax::Spec::Agreement.build({})
    in [:agreement, options]
      Schemax::Spec::Agreement.build(options)

    in [:array, itemspec]
      Schemax::Spec::Array.build(itemspec, {})
    in [:array, itemspec, options]
      Schemax::Spec::Array.build(itemspec, options)

    in :boolean
      Schemax::Spec::Boolean.build({})
    in [:boolean, options]
      Schemax::Spec::Boolean.build(options)

    in :date_time_iso8601
      Schemax::Spec::DateTimeISO8601
    in :date_time_posix
      Schemax::Spec::DateTimePosix

    in [:default, defaultval, subspec]
      Schemax::Spec::Default.build(defaultval, subspec)

    in [:hash, keyspec, valuespec]
      Schemax::Spec::Hash.build(keyspec, valuespec, {})
    in [:hash, keyspec, valuespec, options]
      Schemax::Spec::Hash.build(keyspec, valuespec, options)

    in [:inclusion, options]
      Schemax::Spec::Inclusion.build(options)

    in :integer
      Schemax::Spec::Integer.build({})
    in [:integer, options]
      Schemax::Spec::Integer.build(options)

    in [:literal, value]
      Schemax::Spec::Literal.build(value)
    in ::String
      Schemax::Spec::Literal.build(spec)

    in [:nilable, options]
      Schemax::Spec::Nilable.build(options)

    in [:one_of, *subspecs]
      Schemax::Spec::OneOf.build(subspecs)

    in :string
      Schemax::Spec::String.build({})
    in [:string, options]
      Schemax::Spec::String.build(options)

    in ::Hash
      Schemax::Spec::Record.build(spec)
    end
  end
end