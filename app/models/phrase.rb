class Phrase < ApplicationRecord
  belongs_to :user
  has_many :phrase_tag_relations
  has_many :tags, through: :phrase_tag_relations, dependent: :destroy
  default_scope -> { order(created_at: :desc) }
  validates :user_id, presence: true
  validates :japanese, presence: true
  validates :english, presence: true
end
