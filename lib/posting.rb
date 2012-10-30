class Posting
  def initialize(params = {})
    @posted_at = params[:posted_at]
    @title     = params[:title]
    @price     = params[:price]
    @location  = params[:location]
    @category  = params[:category]
    @url       = params[:url]
  end

  attr_reader :posted_at, :title, :price, :location, :category, :url

  def save(search_result_id, db_name)
    @db = open_db(db_name)
    create_postings_table
    insert_self_into_postings_table
    create_join_table
    insert_join_record(search_result_id)
  end

  private
    def open_db(db_name)
      SQLite3::Database.open(db_name)
    end

    def create_postings_table
      @db.execute "CREATE TABLE IF NOT EXISTS postings(Id INTEGER PRIMARY KEY AUTOINCREMENT,
              Title VARCHAR(100), Price INT, Location VARCHAR(64),
              Category VARCHAR(48), Url VARCHAR(100), Posted_at DATETIME)"
    end

    def insert_self_into_postings_table
      @db.execute "INSERT INTO postings(Title, Price, Location, Category, Url, Posted_at)
                  VALUES(\"#{title}\", \"#{price}\", \"#{location}\", \"#{category}\",
                         \"#{url}\",DATETIME('#{posted_at.strftime('%Y-%m-%d %H:%M:%S')}'))"
    end

    def create_join_table
      @db.execute "CREATE TABLE IF NOT EXISTS search_results_postings(Id INTEGER PRIMARY KEY AUTOINCREMENT, search_result_id INTEGER,
                       posting_id INTEGER)"
    end

    def insert_join_record(search_result_id)
      recent_postings_id = @db.execute "SELECT Id FROM postings ORDER BY Id DESC LIMIT 1"
      @db.execute "INSERT INTO search_results_postings(search_result_id, posting_id)
                   VALUES( #{search_result_id}, #{recent_postings_id[0][0]} )"
    end

end