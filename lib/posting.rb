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
    db = open_db(db_name)
    create_postings_table(db)
    insert_self_into_postings_table(db)
  end

  private
    def open_db(db_name)
      SQLite3::Database.open(db_name)
    end

    def create_postings_table(db)
      db.execute "CREATE TABLE IF NOT EXISTS Postings(Id INTEGER PRIMARY KEY AUTOINCREMENT,
              Title VARCHAR(100), Price INT, Location VARCHAR(64),
              Category VARCHAR(48), Url VARCHAR(100), Posted_at DATETIME)"
    end

    def insert_self_into_postings_table(db)
      db.execute "INSERT INTO Postings(Title, Price, Location, Category, Url, Posted_at)
                  VALUES(\"#{title}\", \"#{price}\", \"#{location}\", \"#{category}\",
                         \"#{url}\",DATETIME('#{posted_at.strftime('%Y-%m-%d %H:%M:%S')}'))"
    end

end