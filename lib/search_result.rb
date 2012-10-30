require 'open-uri'
require 'nokogiri'
require 'date'

class SearchResult
  attr_reader :postings, :time

  def initialize
    @postings = []
    @time
  end

  def self.from_nokogiri(nokogiri, time)
    search_result = self.new
    search_result.time = time
    nokogiri.css('.row').each do |result|
      search_result.postings << Posting.new(parse(result))
    end
    search_result
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

end