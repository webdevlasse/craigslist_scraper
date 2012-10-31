require_relative 'lib/user'
require_relative 'lib/email'

# Get the users from DB, create user objects
users = User.load_all_from_db('beer.db')

# Call email for each user
users.each do |user|
  emailer = Email.new(user)
  emailer.generate_email('beer.db')
end