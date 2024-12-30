# frozen_string_literal: true

module Explicit::Documentation
  Prop = ::Data.define(:name, :description, :partial, :locals) do
    def self.from_spec(spec)
      case spec
      in :string
        just_name("string")
      in [:string, options]
        with_details("string", "explicit/spec/string", { options: })
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