# frozen_string_literal: true

module ResultHelper
  def assert_ok(value, result)
    assert_equal [:ok, value], result
  end

  def assert_error(value, result)
    assert_equal [:error, value], result
  end
end
