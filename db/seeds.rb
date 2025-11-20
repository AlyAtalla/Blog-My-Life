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
  'https://images.unsplash.com/photo-1517816743773-6e0fd518b4a6?auto=format&fit=crop&w=1400&q=80',
  'https://images.unsplash.com/photo-1511203466129-824e631920d4?auto=format&fit=crop&w=1400&q=80',
  'https://images.unsplash.com/photo-1526318472351-c75fcf070d57?auto=format&fit=crop&w=1400&q=80',
  'https://images.unsplash.com/photo-1501425359013-9602f3c4b5a8?auto=format&fit=crop&w=1400&q=80',
  'https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=1400&q=80',
  'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?auto=format&fit=crop&w=1400&q=80',
  'https://images.unsplash.com/photo-1496307042754-2f8b2f7f0f4f?auto=format&fit=crop&w=1400&q=80',
  'https://images.unsplash.com/photo-1515879218367-8466d910aaa4?auto=format&fit=crop&w=1400&q=80',
  'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?auto=format&fit=crop&w=1400&q=80',
  'https://images.unsplash.com/photo-1526316604701-4d8f9d8d4e5a?auto=format&fit=crop&w=1400&q=80'
]

puts "Creating posts..."
titles = [
  'A morning walk through old streets',
  'Why I started journaling again',
  '5 tiny habits that changed my day',
  'The coffee shop that felt like home',
  'Lessons from a failed weekend project',
  'How I organize photos (and why it matters)',
  'A quick guide to mindful coding',
  'On travel: short trips, big memories',
  'The books I keep returning to',
  'Cooking for one: simple and satisfying',
  'Design ideas that actually work',
  'A letter to my past self',
  'Sketches, notes, and small experiments',
  'When silence was the best reply',
  'The tiny joys that keep me going'
]

bodies = [
  'I took a slow walk this morning and noticed how the light fell on the brick. Small things matter.',
  'Journaling returned structure to my day; even five lines can change perspective.',
  'Tiny habit: make your bed. It is boring but oddly stabilizing.',
  'There is a corner table in a cafe where time moves slower and ideas feel safer.',
  'Failure taught me clarity: what to keep and what to let go of quickly.',
  'I keep my photos organized by month; it makes finding memories less painful.',
  'Coding mindfully means taking breaks and reading the code like a story.',
  'Short trips force you to notice the small differences between places.',
  'I reread a handful of books each year; some lines feel new every time.',
  'A single pan and one sheet tray can feed you well for days.',
  'Good design often means less noise and more breathing room.',
  'If I could tell my past self one thing it would be: rest more, rush less.',
  'Sketches are cheap experiments; treat them kindly and often.',
  'Sometimes saying nothing is the most considerate act you can do.',
  'Collect small joys — they compound over time.'
]

# Create 27 posts (3 pages @ 9 posts per page)
27.times do |i|
  user = users.sample
  title = titles.sample + " — ##{i+1}"
  body = bodies.sample + "\n\nThis post was automatically generated for demo purposes and includes practical notes and tiny details to make it feel authentic."
  Post.create!(title: title, body: body, user: user, image_url: images.sample)
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
