require 'rspec'
require 'open-uri'
require 'nokogiri'
require_relative 'spec_helper'

describe SearchResult do

  context ".from_nokogiri" do
    context "returns an instance initialized with the proper number of postings" do
      let(:page) { File.open(File.dirname(__FILE__) + '/fixtures/cl_search.html') }
      let(:nokogiri) { Nokogiri::HTML(page) }
      it "returns an instance initialized with the proper number of postings" do
        result = SearchResult.from_nokogiri(nokogiri, Time.now)
        result.postings.length.should eq 100
      end
    end

    context "initializes without postings" do
      let(:empty_nokogiri) { Nokogiri::HTML(File.open(File.dirname(__FILE__) + '/fixtures/empty_results.html')) }
      it "initializes without postings" do
        result = SearchResult.from_nokogiri(empty_nokogiri, Time.now)
        result.postings.should be_empty
      end
    end

  end

  context "#save" do
    before do
      @search_result = SearchResult.new([Posting.new({posted_at: Time.now, title: 'A title', price: 8.9,
                                        location: 'burlingame', category: 'bicycles - by owner',
                                        url: 'http://sfbay.craigslist.org/pen/bik/3369136014.html'})])
    end

    after do
      db = SQLite3::Database.open('test.db')
      db.execute "DROP TABLE search_results"
      db.execute "DROP TABLE postings"
      db.execute "DROP TABLE search_results_postings"
    end

    it 'saves itself to the db' do
      @search_result.save(1, 'test.db').should be(true)
    end

  end

end