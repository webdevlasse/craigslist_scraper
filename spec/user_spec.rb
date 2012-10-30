require_relative 'spec_helper'

describe User do
  context '#initialize' do
    it 'takes two arguments' do
      User.stub(:save_self_to_db)
      expect(User.new(1, 'email-address')).to be_an_instance_of(User)
    end
  end

  context 'self.load_most_recent_from_db' do
    after do
      db = SQLite3::Database.open('test.db')
      db.execute "DROP TABLE IF EXISTS users"
    end

    it 'returns nil when Users table is empty' do
      User.load_most_recent_from_db('test.db')
    end

    it 'returns the first user in the db' do
      db = SQLite3::Database.open('test.db')
      db.execute "CREATE TABLE IF NOT EXISTS users(Id INTEGER PRIMARY KEY AUTOINCREMENT,
                  Email VARCHAR(80) NOT NULL, Updated_at DATETIME NOT NULL)"
      db.execute "INSERT INTO users(Email, Updated_at) VALUES('rvb@gmail.com', DATETIME('now'))"
      new_user = User.load_most_recent_from_db('test.db')
      expect(new_user.id).to be(1)
      expect(new_user.email).to eq('rvb@gmail.com')
    end
  end

  context 'self.load_by_email_from_db' do
    after do
      db = SQLite3::Database.open('test.db')
      db.execute "DROP TABLE IF EXISTS users"
    end

    it 'returns a user' do
      db = SQLite3::Database.open('test.db')
      db.execute "CREATE TABLE IF NOT EXISTS users(Id INTEGER PRIMARY KEY AUTOINCREMENT,
                  Email VARCHAR(80) NOT NULL, Updated_at DATETIME NOT NULL)"
      db.execute "INSERT INTO users(Email, Updated_at) VALUES('rvb@gmail.com', DATETIME('now'))"
      new_user = User.load_by_email_from_db('test.db', 'rvb@gmail.com')
      expect(new_user.id).to be(1)
      expect(new_user.email).to eq('rvb@gmail.com')
    end

    it 'returns nil when user not found' do
      expect(User.load_by_email_from_db('test.db', 'not_found@whatever.com')).to eq(nil)
    end

    # Note: the below tests 2 methods (.load_by_email_from_db && .load_most_recent_from_db)
    it 'updates the updated_at time' do
      db = SQLite3::Database.open('test.db')
      db.execute "CREATE TABLE IF NOT EXISTS users(Id INTEGER PRIMARY KEY AUTOINCREMENT,
                  Email VARCHAR(80) NOT NULL, Updated_at DATETIME NOT NULL)"
      db.execute "INSERT INTO users(Email, Updated_at) VALUES('rvb@gmail.com', DATETIME('now'))"
      sleep 1
      db.execute "INSERT INTO users(Email, Updated_at) VALUES('dmr@gmail.com', DATETIME('now'))"
      second_user = User.load_by_email_from_db('test.db', 'dmr@gmail.com')
      first_user  = User.load_by_email_from_db('test.db', 'rvb@gmail.com')
      most_recent = User.load_most_recent_from_db('test.db')
      expect(most_recent.email).to eq(first_user.email)
    end
  end

  context 'self.create_and_save' do #(@db_name, new_user_email)
    after do
      db = SQLite3::Database.open('test.db')
      db.execute "DROP TABLE IF EXISTS users"
    end

    it 'returns a new user' do
      new_user = User.create_and_save('test.db', 'rvb@gmail.com')
      expect(new_user.id).to be(1)
      expect(new_user.email).to eq('rvb@gmail.com')
    end

    it 'returns nil when email address not unique' do
      User.create_and_save('test.db', 'rvb@gmail.com')
      duplicate_user = User.create_and_save('test.db', 'rvb@gmail.com')
      expect(duplicate_user).to be(nil)
    end
  end
end