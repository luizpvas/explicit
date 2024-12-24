# frozen_string_literal: true

class Schemax::Request::InvalidParamsError < ::RuntimeError
  attr_reader :errors

  def initialize(errors)
    @errors = errors
  end
end
