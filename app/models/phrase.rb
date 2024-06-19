class Phrase < ApplicationRecord
  belongs_to :user
  has_many :phrase_tag_relations
  has_many :tags, through: :phrase_tag_relations, dependent: :destroy
  default_scope -> { order(created_at: :desc) }
  validates :user_id, presence: true
  validates :japanese, presence: true
  validates :english, presence: true

  scope :search, -> (params) {
    tags = params[:search][:tags].to_unsafe_h.map { |_, tag| tag["name"] }
    return all if tags[0] == ""
    search_by_japanese(params[:search][:japanese])
      .search_by_english(params[:search][:english])
      .search_by_tags(tags)
  }

  scope :search_by_japanese, -> (japanese) {
    return all if japanese.blank?
    where('japanese LIKE ?', "%#{japanese}%")
  }

  scope :search_by_english, -> (english) {
    return all if english.blank?
    where('english LIKE ?', "%#{english}%")
  }

  scope :search_by_tags, -> (tags) {
    return all if tags.blank?
    joins(:phrase_tag_relations).joins(:tags)
      .where(tags: { name: tags })
      .distinct
  }
end
