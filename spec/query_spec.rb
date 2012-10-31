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
    let(:new_query) { Query.new('http://sfbay.craigslist.org/search/sss?query=bike&srchType=A&minAsk=&maxAsk=') }
    it "calls SearchResult.from_Nokogiri passing a Nokogiri object" do
      SearchResult.should_receive(:from_nokogiri)
      new_query.search
    end
    it "returns a new SearchResult instance" do
      SearchResult.stub(:from_nokogiri).and_return(SearchResult.new)
      expect(new_query.search).to be_an_instance_of(SearchResult)
    end

  end

  context "#save" do
    before do
      @query = Query.new('http://sfbay.craigslist.org/search/sss?query=bike&srchType=A&minAsk=&maxAsk=')
      @user = double('user')
      @user.stub(:id).and_return(1)
    end

    after do
      db = SQLite3::Database.open('test.db')
      db.execute "DROP TABLE IF EXISTS queries"
    end

    it 'saves itself to the db' do
      @query.save('test.db', @user).should be(true)
    end

    it 'persists in the db' do
      @query.save('test.db', @user)
      db = SQLite3::Database.open('test.db')
      saved_query = db.execute "SELECT * FROM queries WHERE id=1"
      saved_query[0][0..1].should eq([1, 'http://sfbay.craigslist.org/search/sss?query=bike&srchType=A&minAsk=&maxAsk='])
    end

    it 'calls save on the search results' do
      search_result = double('search_result')
      SearchResult.stub(:from_nokogiri).and_return(search_result)
      @query.search
      search_result.should_receive(:save).with(1, 'test.db')
      @query.save('test.db', @user)
    end
  end

  context "#to_s" do
    it "prints the url" do
      query = Query.new('http://sfbay.craigslist.org/search/sss?query=bike&srchType=A&minAsk=&maxAsk=')
      query.to_s.should eq('http://sfbay.craigslist.org/search/sss?query=bike&srchType=A&minAsk=&maxAsk=')
    end
  end
end