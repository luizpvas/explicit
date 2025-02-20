# frozen_string_literal: true

module API::V1::ArticlesController::Resource
  Type = {
    id: [ :integer, negative: false ],
    title: [ :string, empty: false ],
    content: [ :string, empty: false ],
    published_at: [
      :description,
      <<~MD,
        * When published_at is null it means the article is a draft.
        * When published_at is a moment in the future it means the article
          is scheduled to be published.
        * When published_at is a moment in the past it means the article is
          published and can be read by everyone.
      MD
      [ :nilable, :date_time_iso8601 ]
    ],
    read_count: [ :integer, negative: false ]
  }.freeze

  Serialize = ->(article) do
    article.as_json(only: %i[id title content published_at read_count])
  end
end
