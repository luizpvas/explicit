# frozen_string_literal: true

class Token < ApplicationRecord
  belongs_to :user

  scope :active, -> { where("revoked_at IS NULL AND expires_at > ?", Time.current) }

  before_create :generate_random_token_value

  enum :purpose, { authentication: "authentication" }

  def revoke
    update!(revoked_at: ::Time.current)
  end

  private
    def generate_random_token_value
      self.value = SecureRandom.alphanumeric(20)
    end
end