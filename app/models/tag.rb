class Tag < ApplicationRecord
    # belongs_to :user
    has_many :phrase_tag_relations
    has_many :phrases, through: :phrase_tag_relations
    # validate :check_number_of_tags

    private

    # def check_number_of_tags
    #     if user.tags.count >= 20
    #         errors.add(:base, 'タグをこれ以上登録できません(上限：20)')
    #     end
    # end
end

