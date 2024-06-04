class Phrase < ApplicationRecord
  belongs_to :user
  default_scope -> { order(created_at: :desc) }
  validates :user_id, presence: true
  validates :japanese, presence: true
  validates :english, presence: true
end
