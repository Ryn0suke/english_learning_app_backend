# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
Check.destroy_all
User.destroy_all
Phrase.destroy_all
Tag.destroy_all
PhraseTagRelation.destroy_all
TagUserRelation.destroy_all
User.create!(
  name: "test",
  email: "test@gmail.com",
  password: "password",
  password_confirmation: "password"
)


# 5.times do |n|
#   user = User.create!(
#     name: "test#{n+1}",
#     email: "test#{n+1}@gmail.com",
#     password: "password",
#     password_confirmation: "password"
#   )

#   100.times do
#     user.phrases.create!(
#       japanese: "日本語のフレーズ#{rand(1..100)}",
#       english: "English phrase #{rand(1..100)}"
#     )
#   end
# end
