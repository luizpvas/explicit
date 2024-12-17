# frozen_string_literal: true

module Schema::Type::Composer
  extend self

  def compose(spec_name)
    case spec_name
    in :agreement
      Schema::Type::Agreement.build({})
    in [:agreement, options]
      Schema::Type::Agreement.build(options)

    in [:array, spec]
      Schema::Type::Array.build(spec, {})
    in [:array, spec, options]
      Schema::Type::Array.build(spec, options)

    in :boolean
      Schema::Type::Boolean.build({})
    in [:boolean, options]
      Schema::Type::Boolean.build(options)

    in :date_time_iso8601
      Schema::Type::DateTimeISO8601
    in :date_time_posix
      Schema::Type::DateTimePosix

    in [:default, defaultval, options]
      Schema::Type::Default.build(defaultval, options)

    in [:inclusion, options]
      Schema::Type::Inclusion.build(options)

    in :integer
      Schema::Type::Integer.build({})
    in [:integer, options]
      Schema::Type::Integer.build(options)

    in [:nilable, options]
      Schema::Type::Nilable.build(options)

    in :string
      Schema::Type::String.build({})
    in [:string, options]
      Schema::Type::String.build(options)

    in ::Hash
      Schema::Type::Schema.build(spec_name)
    end
  end
end
