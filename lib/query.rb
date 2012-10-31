# require_relative './search_result'
require 'nokogiri'
require 'open-uri'

class NotCraigsListError < StandardError
  def message
    "Not the right url"
  end
end

class Query
  def initialize(url)
    raise NotCraigsListError unless url =~ /craigslist/
    @url = url
  end

  def search
    @search_result = SearchResult.from_nokogiri(url_to_nokogiri_document, Time.now)
  end

  def save(db_name, user)
    begin
      @db = open_db(db_name)
      create_queries_table
      insert_self_into_queries_table(user)
      id = retrieve_id_from_db
      @search_result.save(id, db_name) if @search_result
      true
    rescue
      false
    end
  end

  def to_s
    @url
  end

  private
    def url_to_nokogiri_document
      Nokogiri::HTML(open(@url))
    end

    def open_db(db_name)
      SQLite3::Database.open(db_name)
    end

    def create_queries_table
      @db.execute "CREATE TABLE IF NOT EXISTS queries(Id INTEGER PRIMARY KEY AUTOINCREMENT,
                   Url VARCHAR(100), User_id INT, Created_at DATETIME, Unique (Url, User_id))"
    end

    def insert_self_into_queries_table(user)
      @db.execute "INSERT INTO queries(Url, User_id, Created_at)
                   VALUES('#{@url}', #{user.id}, DATETIME('now'))"
    end

    def retrieve_id_from_db
      id = @db.execute "SELECT Id FROM queries ORDER BY Created_at DESC LIMIT 1"
      id[0][0]
    end
end