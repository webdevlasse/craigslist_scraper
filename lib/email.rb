require 'restclient'
require 'multimap'

class Email

  def initialize
    @content = {}
  end

  def self.generate_email(user, db_name)
    @db = open_db(db_name)
    queries(user).each do |query|
      @content[query] = postings(search_result(query))
    end
    send_email
  end

  # created for the purpose of testing without the user class
  # def generate(db_name)
  #   @db = open_db(db_name)
  #   queries.each do |query|
  #     @content[query] = postings(search_result(query))
  #   end
  #   send_email
  # end

  def open_db(db_name)
    SQLite3::Database.open(db_name)
  end

  def queries(user)
    @db.execute "SELECT * FROM queries WHERE user_id = #{user.id}"
  end

  # created for the purpose of testing without the user class
  # def queries
  #   @db.execute "SELECT * FROM queries LIMIT 1"
  # end

  def search_result(query)
    @db.execute "SELECT * FROM search_results WHERE query_id = #{query[0]} ORDER BY searched_at DESC LIMIT 1"
  end

  def postings(search_result)
    search_results_postings_data = @db.execute "SELECT * FROM search_results_postings WHERE search_result_id = #{search_result[0][0]}"
    search_results_postings_data.each { |posting| posting[2] = @db.execute "SELECT * FROM postings WHERE id = #{posting[2]}" }
  end

  # add the "Latest scrape date/time"
  def generate_email_body
    @text = ""
    @content.each do |query, postings|
      @text << <<-STRING
        #{query[1]}
        Searched on: #{format_date(query[2])}

      STRING
      postings.each { |posting| @text << "#{posting[2][0][1]}\n#{posting[2][0][5]}\n$#{posting[2][0][2]}\n\n" }
    end
    @text
  end

  def format_date(date)
    date.gsub(/(\d{4})-(\d{1,2})-(\d{1,2}).*/, '\3-\2-\1')
  end

  def send_email
    data = Multimap.new
    data[:from] = "Guillaume <user@organizedbeer.mailgun.org>"  #This will be the from, make sure to have your provided email address in <>
    data[:to] = "webdevlasse@gmail.com", "rvbsanjose@me.com", "dmragone@gmail.com", "guillaume.galuz@gmail.com"
    data[:subject] = "Craigslist Digest - #{Time.now.month}/#{Time.now.day}/#{Time.now.year}"
    data[:text] = generate_email_body
    RestClient.post "https://api:key-2vry40wfv2ptvmzp-4hb1mpt1uzxesb9"\
    "@api.mailgun.net/v2/organizedbeer.mailgun.org/messages", data
  end

end