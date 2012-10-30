require 'rspec'
require 'open-uri'
require 'nokogiri'
require './lib/search_result.rb'

describe ".from_nokogiri" do

  context "when there are search results" do
    let(:page) { File.open('spec/fixtures/cl_search.html') }
    let(:nokogiri) { Nokogiri::HTML(page) }

    it "returns an instance initialized with the proper number of postings" do
      result = SearchResult.from_nokogiri(nokogiri, Time.now)
      result.postings.length.should eq 100
    end

  end

  context "when there are no search results" do
    let(:empty_nokogiri) { Nokogiri::HTML(File.open('spec/fixtures/empty_results.html')) }

    it "initializes without postings" do
      result = SearchResult.from_nokogiri(empty_nokogiri, Time.now)
      result.postings.should be_empty
    end
  end

end