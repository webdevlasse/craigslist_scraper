require_relative 'query'
require_relative 'search_result'
require_relative 'posting'
require_relative 'user'

class CraigslistUI
  def initialize(db_name)
    @db_name = db_name
    @current_user = current_user
  end

  def start_organized_beer
    prompts
    until (input = gets.chomp) == 'exit'
      case input
      when 'create' then create_query
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
      puts "What Craigslist url would you like to query?"
      url = gets.chomp
      query = Query.new(url)
      query.search
      query.save(@db_name, @current_user)
    end

    def list_queries # NOTE: move logic to Query class
      db = SQLite3::Database.open(@db_name)
      queries = db.execute "SELECT * FROM queries WHERE user_id='#{@current_user.id}'"
      queries.each { |query| puts query }
    end

    def current_user
      User.load_most_recent_from_db(@db_name)
    end

    def change_user
      puts "What email do you want to sign in as?"
      new_user_email = gets.chomp
      new_user = User.load_by_email_from_db(@db_name, new_user_email)
      if new_user.nil?
        puts "Email address not found"
      else
        @current_user = new_user
      end
    end

    def create_user # NOTE: need to handle error if email is not unique (uniqueness enforced by db)
      puts "What email do you want to use?"
      new_user_email = gets.chomp
      new_user = User.create_and_save(@db_name, new_user_email)
      if new_user.nil?
        puts "User email already exists"
      else
        @current_user = new_user
      end
    end
end