class CreateTokens < ActiveRecord::Migration[7.2]
  def change
    create_table :tokens do |t|
      t.belongs_to :user, null: false
      t.string :purpose, null: false
      t.string :value, null: false, index: { unique: true }
      t.string :ip_address, null: false
      t.string :user_agent
      t.datetime :expires_at, null: false
      t.datetime :revoked_at
      t.timestamps
    end
  end
end
