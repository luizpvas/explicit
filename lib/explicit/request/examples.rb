# frozen_string_literal: true

class Explicit::Request::Examples
  def initialize
    @records = {}
  end

  def add(request, params:, headers:, response:)
    raise NotImplementedError
  end

  def save_to_file
    raise NotImplementedError
  end

  def read_from_file
    raise NotImplementedError
  end
end
