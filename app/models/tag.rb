class Tag < ApplicationRecord
    has_many :phrase_tag_relations, dependent: :destroy
    has_many :phrases, through: :phrase_tag_relations
    accepts_nested_attributes_for :phrase_tag_relations
    has_many :tag_user_relations, dependent: :destroy
    has_many :users, through: :tag_user_relations
    accepts_nested_attributes_for :tag_user_relations
end