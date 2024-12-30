# frozen_string_literal: true

module Explicit::Documentation
  Prop = ::Data.define(:name, :description, :partial, :locals) do
    def self.from_spec(spec)
      case spec
      in :string
        just_name("string")
      in [:string, options]
        with_partial("string", "spec/string", { options: })
      end
    end

    def self.just_name(name)
      new(name:, description: nil, partial: nil, locals: nil)
    end

    def self.with_partial(name, partial, locals)
      new(name:, description: nil, partial:, locals:)
    end
  end
end