# frozen_string_literal: true

module Explicit
  module ApplicationHelper
    def spec_render(spec)
      render partial: spec.partial, locals: { spec: }
    end

    def spec_has_details?(spec)
      spec.description.present? || spec.has_details?
    end
  end
end
