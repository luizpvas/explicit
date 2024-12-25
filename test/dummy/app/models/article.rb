# frozen_string_literal: true

class Article < ApplicationRecord
  belongs_to :user

  scope :published, -> { where("published_at < ?", ::Time.current) }

  validates :title, presence: true
  validates :content, presence: true

  def published?
    published_at&.past?
  end
end
