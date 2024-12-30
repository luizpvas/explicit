# frozen_string_literal: true

module Explicit::Documentation
  Prop = ::Data.define(:name, :description, :default, :allowed_values, :partial, :locals) do
    def self.from_spec(spec)
      case spec
      in :agreement
        with_details("agreement", "explicit/spec/agreement", options: {})
      in [:agreement, options]
        with_details("agreement", "explicit/spec/agreement", options:)
      in [:array, subspec]
        with_details("array", "explicit/spec/array", subprop: from_spec(subspec), options: {})
      in [:array, subspec, options]
        with_details("array", "explicit/spec/array", subprop: from_spec(subspec), options:)
      in :bigdecimal
        with_details("bigdecimal", "explicit/spec/bigdecimal", options: {})
      in [:bigdecimal, options]
        with_details("bigdecimal", "explicit/spec/bigdecimal", options:)
      in :boolean
        just_name("boolean")
      in [:boolean, options]
        with_details("boolean", "explicit/spec/boolean", options:)
      in :date_time_iso8601
        with_details("date_time_iso8601", "explicit/spec/date_time_iso8601", options: {})
      in :date_time_posix
        with_details("date_time_posix", "explicit/spec/date_time_posix", options: {})
      in [:default, default, subspec]
        from_spec(subspec).with(default:)
      in [:description, description, subspec]
        from_spec(subspec).with(description:)
      in [:hash, keyspec, valuespec]
        with_details(
          "hash",
          "explicit/spec/hash",
          keyprop: from_spec(keyspec),
          valueprop: from_spec(valuespec),
          options: {}
        )
      in [:hash, keyspec, valuespec, options]
        with_details(
          "hash",
          "explicit/spec/hash",
          keyprop: from_spec(keyspec),
          valueprop: from_spec(valuespec),
          options:
        )
      in [:inclusion, allowed_values]
        with_details("enum", "explicit/spec/inclusion", allowed_values:).with(allowed_values:)
      in :string
        just_name("string")
      in [:string, options]
        with_details("string", "explicit/spec/string", options:)
      end
    end

    def self.just_name(name)
      new(name:, description: nil, default: nil, allowed_values: nil, partial: nil, locals: nil)
    end

    def self.with_details(name, partial, locals)
      new(name:, description: nil, default: nil, allowed_values: nil, partial:, locals:)
    end

    def renders_successfully?
      return true if partial.nil?

      Explicit::ApplicationController.render(partial:, locals:)

      true
    end
  end
end