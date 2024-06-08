class PhraseTagRelation < ApplicationRecord
  belongs_to :phrase
  belongs_to :tag
end
