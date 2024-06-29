class Phrase < ApplicationRecord
  belongs_to :user
  has_many :phrase_tag_relations
  has_many :tags, through: :phrase_tag_relations, dependent: :destroy
  has_one :check
  default_scope -> { order(created_at: :desc) }
  validates :user_id, presence: true
  validates :japanese, presence: true
  validates :english, presence: true

  scope :search, -> (params) {
    # puts params[:search][:isPartialMatch]

    # if params[:search][:isPartialMatch] == "false" 
    #   puts "falsedesu"
    # end

    is_partial_match = judge_partial_match(params)

    tags = params[:search][:tags].to_unsafe_h.map { |_, tag| tag["name"] }

    # puts "-----------------"
    # puts params[:search]
    # puts "-----------------"

    search_by_check_state(params[:search][:state1], params[:search][:state2], params[:search][:state3], is_partial_match)
      .search_by_japanese(params[:search][:japanese], is_partial_match)
      .search_by_english(params[:search][:english], is_partial_match)
      .search_by_tags(tags)
  }

  scope :search_for_question, -> (params) {
    tags = params[:option][:tags].to_unsafe_h.map { |_, tag| tag["name"] }

    puts "-----------------aaaaaaaa"
    puts tags
    puts "-----------------aaaaaaaa"

    search_by_check_state(params[:option][:state1], params[:option][:state2], params[:option][:state3], true)
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

  scope :search_by_check_state, -> (state1, state2, state3, isPartialMatch) {
    if (state1.blank? && state2.blank? && state3.blank?)
      return all
    else
      conditions = {}

      if isPartialMatch
        conditions[:state1] = judge_state(state1) if judge_state(state1)
        conditions[:state2] = judge_state(state2) if judge_state(state2)
        conditions[:state3] = judge_state(state3) if judge_state(state3)
      else
        conditions[:state1] = judge_state(state1)
        conditions[:state2] = judge_state(state2)
        conditions[:state3] = judge_state(state3)
      end
    end
    

    puts "\n\n\n\n\n\n\n -------------"
    puts conditions
    puts "\n\n\n\n\n\n\n -------------"

    if conditions.blank?
      return all
    else
      return joins(:check).where(check: conditions)
    end
  }
  

  scope :search_by_tags, -> (tags) {
    return all if tags[0] == "" || tags.blank?
    # if tags[0] == "" || tags.blank?
    #   puts "\n\n\n\n\n\n\n tagstags \n\n\n\n\n\n\n"
    #   return all
    # end
    # return all if tags.blank?
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
