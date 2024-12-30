# frozen_string_literal: true

module Explicit::Documentation
  Prop = ::Data.define(:name, :description, :partial, :locals) do
    def self.from_spec(spec)
      case spec
      in :agreement
        with_details("agreement", "explicit/spec/agreement", options: {})
      in [:agreement, options]
        with_details("agreement", "explicit/spec/agreement", options:)
      in [:description, description, subspec]
        from_spec(subspec).with(description:)
      in :string
        just_name("string")
      in [:string, options]
        with_details("string", "explicit/spec/string", options:)
      end
    end

    def self.just_name(name)
      new(name:, description: nil, partial: nil, locals: nil)
    end

    def self.with_details(name, partial, locals)
      new(name:, description: nil, partial:, locals:)
    end

    def renders_successfully?
      return true if partial.nil?

      Explicit::ApplicationController.render(partial:, locals:)

      true
    end
  end
end