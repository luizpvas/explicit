module Schema
  module Api
    class ApplicationRecord < ActiveRecord::Base
      self.abstract_class = true
    end
  end
end
