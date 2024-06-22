class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_many :phrases, dependent: :destroy
  has_many :tag_user_relations, dependent: :destroy
  has_many :tags, through: :tag_user_relations
  has_many :checks, dependent: :destroy
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  include DeviseTokenAuth::Concerns::User
end
