require_relative 'query'
require_relative 'search_result'
require_relative 'posting'
require_relative 'user'

class CraigslistUI
  def initialize(db_name)
    @db_name = db_name
    @current_user = current_user
  end

  def request_input
    prompts
    until (input = gets.chomp) == 'exit'
      case input
      when 'create' then create_query(input)
      when 'list'   then list_queries
      when 'signin' then change_user
      when 'signup' then create_user
      end
      prompts
    end
  end

  private

    def prompts
      puts "Currently signed in as #{@current_user.email}"
      puts "What would you like to do? ('create' to create a query, 'list' to list your queries, \
      'signin' to change users, 'signup' to create a new account, 'exit')"
    end

    def create_query(url)
      query = Query.new(url)
      query.search
      query.save(@db_name, @current_user)
    end

    def list_queries
      db = SQLite3::Database.open(@db_name)
      queries = db.execute "SELECT * FROM queries WHERE user_id='#{@current_user.id}'"
      queries.each { |query| puts query }
    end

    def current_user
      db = SQLite3::Database.open(@db_name)
      most_recent_user = (db.execute "SELECT * FROM users ORDER BY updated_at DESC LIMIT 1")[0]
      User.new(id, email)
    end

    def change_user
      puts "What email do you want to sign in as?"
      new_user_email = gets.chomp
      db = SQLite3::Database.open(@db_name)
      new_user = db.execute "SELECT * FROM users WHERE email='#{new_user_email}'"
      if new_user.empty?
        puts "Email address not found"
      else
        @current_user = User.new(new_user[0][0], new_user[0][1])
      end
    end

    def create_user
      puts "What email do you want to use?"
      db = SQLite3::Database.open(@db_name)
      new_user_email = gets.chomp
      db.execute "INSERT INTO users(email, updated_at) VALUES ('#{new_user_email}', DATETIME('now'))"
      new_user_id = (db.execute "SELECT Id FROM users WHERE email='#{new_user_email}'")[0][0]
      @current_user = User.new(new_user_id, new_user_email)
    end
end




# Usage
# What do you want to do? (create query, list queries)