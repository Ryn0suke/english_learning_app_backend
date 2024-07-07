class Phrase < ApplicationRecord
  belongs_to :user
  has_many :phrase_tag_relations
  has_many :tags, through: :phrase_tag_relations, dependent: :destroy
  has_one :check
  default_scope -> { order(created_at: :desc) }
  validates :user_id, presence: true
  validates :japanese, presence: true, length: { maximum: 50 }
  validates :english, presence: true, length: { maximum: 50 }

  scope :search, -> (params) {

    is_partial_match = judge_partial_match(params)

    if params[:search][:tags]
      tags = params[:search][:tags].to_unsafe_h.map { |_, tag| tag["name"] }
    else
      tags = []
    end


    search_by_check_state(params[:search][:state1], params[:search][:state2], params[:search][:state3], params[:search][:state4], is_partial_match)
      .search_by_japanese(params[:search][:japanese], is_partial_match)
      .search_by_english(params[:search][:english], is_partial_match)
      .search_by_tags(tags)
  }

  scope :search_for_question, -> (params) {
    if params[:option][:tags]
      tags = params[:option][:tags].to_unsafe_h.map { |_, tag| tag["name"] }
    else
      tags = []
    end

    search_by_check_state(params[:option][:state1], params[:option][:state2], params[:option][:state3], params[:option][:state4], true)
    .search_by_tags(tags)
  }

  scope :search_by_japanese, -> (japanese, isPartialMatch) {
    return all if japanese.blank?
    isPartialMatch ? where("japanese LIKE ?", "%#{japanese}%") : where("japanese = ?", japanese)
  }

  scope :search_by_english, -> (english, isPartialMatch) {
    return all if english.blank?
    isPartialMatch ? where("english LIKE ?", "%#{english}%") : where("english = ?", english)
  }

  scope :search_by_check_state, -> (state1, state2, state3, state4, isPartialMatch) {
    if state1.blank? && state2.blank? && state3.blank?
      all
    elsif judge_state(state4)
      joins(:check).where(checks: { state1: false, state2: false, state3: false })
    else
      conditions = []
      values = []
  
      if isPartialMatch
        conditions << "checks.state1 = ?" if state1.present? && judge_state(state1)
        values << judge_state(state1) if state1.present? && judge_state(state1)
  
        conditions << "checks.state2 = ?" if state2.present? && judge_state(state2)
        values << judge_state(state2) if state2.present? && judge_state(state2)
  
        conditions << "checks.state3 = ?" if state3.present? && judge_state(state3)
        values << judge_state(state3) if state3.present? && judge_state(state3)
  
        where_clause = conditions.join(' OR ')

      else
        conditions << "checks.state1 = ?" if state1.present?
        values << judge_state(state1) if state1.present?
  
        conditions << "checks.state2 = ?" if state2.present?
        values << judge_state(state2) if state2.present?
  
        conditions << "checks.state3 = ?" if state3.present?
        values << judge_state(state3) if state3.present?
  
        where_clause = conditions.join(' AND ')
      end
  
      joins(:check).where(where_clause, *values)
    end
  }

  scope :search_by_tags, -> (tags) {
    return all if tags[0] == "" || tags.blank?

    joins(:phrase_tag_relations).joins(:tags)
      .where(tags: { name: tags })
      .distinct
  }

  private
  
  def self.judge_partial_match(params)
    params[:search][:isPartialMatch] == "true" ? true : false
  end

  def self.judge_state(state)
    state == "true" ? true : false
  end

end
