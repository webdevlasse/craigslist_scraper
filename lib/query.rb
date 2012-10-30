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
    SearchResult.from_nokogiri(url_to_nokogiri_document, Time.now)
  end

  private
    def url_to_nokogiri_document
      Nokogiri::HTML(open(@url))
    end
end