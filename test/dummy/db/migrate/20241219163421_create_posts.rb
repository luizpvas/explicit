class CreatePosts < ActiveRecord::Migration[7.2]
  def change
    create_table :posts do |t|
      t.belongs_to :user, null: false
      t.string :title
      t.string :content
      t.datetime :published_at
      t.timestamps
    end
  end
end
