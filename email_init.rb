require_relative 'lib/user'
require_relative 'lib/query'
require_relative 'lib/search_result'
require_relative 'lib/email'

# Get the users from DB, create user objects
users = User.load_all_from_db('beer.db')

# Create query object for each query for each user, run 'search' on it
db = SQLite3::Database.open('beer.db')
users.each do |user|
  queries = db.execute "SELECT * FROM queries WHERE user_id = #{user.id}"
  queries.each do |query|
    new_query = Query.new(query[1])
    new_query.search
    new_query.save('beer.db', user)
  end
end

# Call email for each user
users.each do |user|
  emailer = Email.new(user)
  emailer.generate_email('beer.db')
end
