# frozen_string_literal: true

class Token < ApplicationRecord
  belongs_to :user

  before_create :generate_random_token_value

  enum :purpose, { authentication: "authentication" }

  private
    def generate_random_token_value
      self.value = SecureRandom.alphanumeric(20)
    end
end