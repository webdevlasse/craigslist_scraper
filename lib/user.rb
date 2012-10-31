require 'sqlite3'

class User
  def initialize(id, email, last_emailed_at = nil)
    @id = id
    @email = email
    @last_emailed_at = last_emailed_at || DateTime.parse('2000-01-01')
  end

  attr_reader :id, :email, :last_emailed_at

  def self.load_all_from_db(db_name)
    open_db(db_name)
    user_data = @db.execute "SELECT * FROM users"
    users = []
    user_data.each do |user|
      users << User.new(user[0], user[1], DateTime.parse(user[3]))
    end
    users
  end

  def self.load_most_recent_from_db(db_name)
    open_db_and_create_users_table(db_name)
    user_record = most_recent_user
    self.new(user_record[0], user_record[1]) unless user_record.nil?
  end

  def self.load_by_email_from_db(db_name, email)
    open_db_and_create_users_table(db_name)
    user_record = find_user(email)
    update_found_user_updated_at(user_record[0]) unless user_record.nil?
    self.new(user_record[0], user_record[1]) unless user_record.nil?
  end

  def self.create_and_save(db_name, email)
    begin
      open_db_and_create_users_table(db_name)
      create_user(email)
      load_most_recent_from_db(db_name)
    rescue
      nil
    end
  end

  def update_last_emailed_at!(db_name)
    db = SQLite3::Database.open(db_name)
    db.execute "UPDATE users
                SET Last_emailed_at = DATETIME('now')
                WHERE id = #{self.id} "
  end

  private
    def save_self_to_db
      raise StandardError
    end

    def self.open_db_and_create_users_table(db_name)
      open_db(db_name)
      create_users_table
    end

    def self.open_db(db_name)
      @db = SQLite3::Database.open(db_name)
    end

    def self.create_users_table
      @db.execute "CREATE TABLE IF NOT EXISTS users(Id INTEGER PRIMARY KEY AUTOINCREMENT,
                  Email VARCHAR(80) NOT NULL, Updated_at DATETIME NOT NULL, Last_emailed_at DATETIME)"
      @db.execute "CREATE UNIQUE INDEX IF NOT EXISTS UniqueEmail ON Users (email)"
    end

    def self.update_found_user_updated_at(id)
      @db.execute "UPDATE users SET Updated_at=DATETIME('now') WHERE id=#{id}"
    end

    def self.most_recent_user
       (@db.execute "SELECT * FROM users ORDER BY updated_at DESC LIMIT 1")[0]
    end

    def self.find_user(email)
      (@db.execute "SELECT * FROM users WHERE email = '#{email}'")[0]
    end

    def self.create_user(email)
      @db.execute "INSERT INTO users (Email, Updated_at) VALUES ('#{email}', DATETIME('now'))"
    end
end