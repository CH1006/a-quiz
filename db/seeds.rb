User.create!( email: "admin@gmail.com", name: "Admin", password: "123123", role: "admin")
User.create!( email: "member@gmail.com", name: "Member", password: "123123", role: "member")
User.create!( email: "admin1@gmail.com", name: "Admin1", password: "123123", role: "admin")
User.create!( email: "admin2@gmail.com", name: "Admin2", password: "123123", role: "admin")

["Ruby","Javascript", "Mysql", "HTML", "ReactJs"].each do |name|
  Category.create! name: name, user_id: User.where(role: "admin").sample.id
end

# 200.times do |q|
#   Question.new(category_id: rand(1..5), question_content: "Question name #{q+1}", level: rand(0..1)).save(validate: false)
#   Answer.create!(question_id: q+1, content: "true", status: true)
#   Answer.create!(question_id: q+1, content: "false", status: false)
# end
