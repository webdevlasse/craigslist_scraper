require_relative 'spec_helper'

describe Query do

  context"#initialize" do
    it "accepts one url" do
      new_query = Query.new('http://sfbay.craigslist.org/search/sss?query=bike&srchType=A&minAsk=&maxAsk=')
      new_query.should be_instance_of Query
    end

    it "only accepts one url" do
      expect { Query.new('http://sfbay.craigslist.org/search/sss?query=bike&srchType=A&minAsk=&maxAsk=',
        'http://sfbay.craigslist.org/search/sss?query=bike&srchType=A&minAsk=&maxAsk=')
        }.to raise_error(ArgumentError)
    end

    it "confirms it is a valid craigslist url" do
      expect { Query.new('http://somebadurl.org') }.to raise_error(NotCraigsListError)
    end
  end

  context "#search" do
    it "calls SearchResult.from_Nokogiri passing a Nokogiri object" do
      new_query = Query.new('http://sfbay.craigslist.org/search/sss?query=bike&srchType=A&minAsk=&maxAsk=')
      SearchResult.should_receive(:from_nokogiri).with(Nokogiri::HTML::Document)
      new_query.search
    end
    it "returns a new SearchResult instance" do
      new_query = Query.new('http://sfbay.craigslist.org/search/sss?query=bike&srchType=A&minAsk=&maxAsk=')
      SearchResult.stub(:from_nokogiri).and_return(SearchResult.new)
      expect(new_query.search).to be_an_instance_of(SearchResult)
    end

  end

  context "#save" do
    it "should save its items to the database"
  end
end