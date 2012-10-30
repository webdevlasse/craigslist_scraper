require_relative 'spec_helper'

describe Posting do
  context "#initialize" do

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
                                  price: 8, location: 'burlingame',
                                  category: 'bicycles - by owner',
                                  url: 'http://sfbay.craigslist.org/pen/bik/3369136014.html'})
    end

    after do
      db = SQLite3::Database.open('test.db')
      db.execute "DROP TABLE Postings"
    end

    it 'saves itself to the db' do
      @new_posting.save(1, 'test.db').should eq([])
    end

    it 'persists in the db' do
      @new_posting.save(1, 'test.db').should eq([])
      db = SQLite3::Database.open('test.db')
      saved_posting = db.execute "SELECT * FROM Postings WHERE id=1"
      saved_posting.should eq([[1, 'A title', 8, 'burlingame', 'bicycles - by owner',
                               'http://sfbay.craigslist.org/pen/bik/3369136014.html',
                               @time.strftime('%Y-%m-%d %H:%M:%S')]])
    end
  end
end