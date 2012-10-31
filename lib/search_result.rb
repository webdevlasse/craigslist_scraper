require 'open-uri'
require 'nokogiri'
require 'date'
require_relative 'posting'
require 'sqlite3'

class SearchResult
  attr_reader :postings
  attr_accessor :searched_at

  def initialize(postings = [])
    @postings = postings
    @searched_at
  end

  def self.from_nokogiri(nokogiri, searched_at)
    search_result = self.new
    search_result.searched_at = searched_at
    nokogiri.css('.row').each do |result|
      search_result.postings << Posting.new(parse(result))
    end
    search_result
  end

  def save(query_id, db_name)
    # begin
      @db = open_db(db_name)
      create_search_results_table
      insert_self_into_search_results_table(query_id)
      id = retrieve_id_from_db
      @postings.each { |posting| posting.save(id, db_name) }
      true
    # rescue
    #   false
    # end
  end

  private
    def self.parse(row)
      posted_at = Date.parse(row.at_css(".itemdate").text.strip)
      title = row.at_css("a").text.strip
      price = row.at_css(".itempp").text.strip.gsub(/[$](\d+)/, '\1')
      location = row.at_css(".itempn").text.strip.gsub(/[(](.+)[)]/, '\1')
      category = row.at_css(".itemcg").text.strip
      url = row.at_css("a").attributes["href"].value
      {:posted_at => posted_at, :title => title, :price => price, :location => location, :category => category, :url => url }
    end

    def open_db(db_name)
      SQLite3::Database.open(db_name)
    end

    def create_search_results_table
      @db.execute "CREATE TABLE IF NOT EXISTS search_results(Id INTEGER PRIMARY KEY AUTOINCREMENT,
              searched_at DATETIME, query_id INT)"
    end

    def insert_self_into_search_results_table(query_id)
      @db.execute "INSERT INTO search_results(searched_at, query_id)
                   VALUES (\"#{self.searched_at}\", \"#{query_id}\")"
    end

    def retrieve_id_from_db
      (@db.execute "SELECT Id FROM search_results ORDER BY Id desc LIMIT 1")[0][0]
    end

end