require_relative 'spec_helper'

describe Posting do
  context "setters" do
    new_posting = Posting.new({posted_at: @time, title: 'A title',
                                price: 8.9, location: 'burlingame',
                                category: 'bicycles - by owner',
                                url: 'http://sfbay.craigslist.org/pen/bik/3369136014.html'})
    subject { new_posting }
    [:posted_at, :title, :price, :location, :category, :url].each do |method|
      it { should respond_to(method) }
    end
  end

  context '#attr_reader' do
    it "should allow the attributes to be read" do
      new_posting = Posting.new({:title  => "Trek Bike", :price => 500})
      new_posting.title.should eq "Trek Bike"
      new_posting.price.should eq 500
    end
  end

  context '#save' do
    before do
      @time = Time.now
      @new_posting = Posting.new({posted_at: @time, title: 'A title',
                                  price: 8.9, location: 'burlingame',
                                  category: 'bicycles - by owner',
                                  url: 'http://sfbay.craigslist.org/pen/bik/3369136014.html'})
    end

    after do
      db = SQLite3::Database.open('test.db')
      db.execute "DROP TABLE postings"
    end

    it 'saves itself to the db' do
      @new_posting.save(1, 'test.db').should be(true)
    end

    it 'persists in the db' do
      @new_posting.save(1, 'test.db')
      db = SQLite3::Database.open('test.db')
      saved_posting = db.execute "SELECT * FROM postings WHERE id=1"
      saved_posting.should eq([[1, 'A title', 8.9, 'burlingame', 'bicycles - by owner',
                               'http://sfbay.craigslist.org/pen/bik/3369136014.html',
                               @time.strftime('%Y-%m-%d')]])
    end

    it "creates a record in the join table" do
      @new_posting.save(1, 'test.db')
      db = SQLite3::Database.open('test.db')
      join = db.execute "SELECT * FROM search_results_postings LIMIT 1 "
      join.should eq([[1, 1, 1]])

    end

    it "returns false when date is not DateTime object" do
      bad_posting = Posting.new({posted_at: 'bad', title: 'A title'})
      expect(bad_posting.save(1, 'test.db')).to be(false)
    end
  end
end