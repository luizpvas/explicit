# frozen_string_literal: true

module ValidationHelper
  def type(typespec)
    Explicit::Type.build(typespec)
  end

  def validate(value, typespec)
    type = type(typespec)

    assert_webpage!(type)
    assert_swagger_schema!(type)
    assert_mcp_schema!(type)

    type.validate(value)
  end

  def assert_webpage!(type)
    assert [ true, false ].include?(type.has_details?)
    assert type.summary.present?

    if type.has_details?
      ::Explicit::ApplicationController.render(
        partial: type.partial,
        locals: { type: }
      )
    end
  end

  def assert_swagger_schema!(type)
    assert type.swagger_schema.is_a?(::Hash)
  end

  def assert_mcp_schema!(type)
    assert type.mcp_schema.is_a?(::Hash)
  rescue ::NotImplementedError
    :ok
  end
end
