# Seeds: create users, posts, comments and likes (idempotent)

puts "Cleaning DB..."
Comment.delete_all
Like.delete_all
Post.delete_all
User.delete_all

puts "Creating users..."
users = []
5.times do |i|
	users << User.create!(name: "User#{i+1}", email: "user#{i+1}@example.com", password: 'password', password_confirmation: 'password')
end

images = [
	'https://images.unsplash.com/photo-1503264116251-35a269479413?auto=format&fit=crop&w=1400&q=80',
	'https://images.unsplash.com/photo-1496307042754-b4aa456c4a2d?auto=format&fit=crop&w=1400&q=80',
	'https://images.unsplash.com/photo-1508921912186-1d1a45ebb3c1?auto=format&fit=crop&w=1400&q=80',
	'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=1400&q=80',
	'https://images.unsplash.com/photo-1517816743773-6e0fd518b4a6?auto=format&fit=crop&w=1400&q=80'
]

puts "Creating posts..."
15.times do |i|
	user = users.sample
	Post.create!(title: "Sample Post #{i+1}", body: "This is a seeded sample post number #{i+1}. Enjoy the content!", user: user, image_url: images.sample)
end

puts "Creating comments..."
Post.all.each do |post|
	rand(0..3).times do
		Comment.create!(body: "Nice post!", user: users.sample, post: post)
	end
end

puts "Creating likes..."
Post.all.each do |post|
	users.sample(rand(0..3)).each do |u|
		Like.find_or_create_by!(user: u, post: post)
	end
end

puts "Seeded: users=#{User.count} posts=#{Post.count} comments=#{Comment.count} likes=#{Like.count}"
