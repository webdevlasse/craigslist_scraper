require 'restclient'
require 'multimap'

class Email

  def initialize(user)
    @user = user
    @content = {}
  end

  attr_reader :content

  def generate_email(db_name)
    open_db(db_name)
    queries.each do |query|
      content[query] = fetch_postings(search_result(query))
    end
    send_email
    @user.update_last_emailed_at!(db_name)
  end

  def open_db(db_name)
    @db = SQLite3::Database.open(db_name)
  end

  def queries
    @db.execute "SELECT * FROM queries WHERE user_id = #{@user.id}"
  end

  def search_result(query)
    @db.execute "SELECT * FROM search_results WHERE query_id = #{query[0]} ORDER BY searched_at DESC LIMIT 1"
  end

  def fetch_postings(search_result)
    @db.execute "SELECT *
                 FROM Postings
                 INNER JOIN search_results_postings
                 ON Postings.id = search_results_postings.posting_id
                 WHERE search_results_postings.search_result_id = #{search_result[0][0]} AND Postings.posted_at > DATE('#{@user.last_emailed_at.strftime('%Y-%m-%d')}')"
  end

  def generate_email_body
    @text = ""
    @content.each do |query, postings|
      @text << <<-STRING
        #{query[1]}
        Searched on: #{format_date(query[3])}

      STRING
      postings.each { |posting| @text << "#{posting[1]}\n#{posting[5]}\n$#{posting[2]}\n\n" }
    end
    @text
  end

  def format_date(date)
    date.gsub(/(\d{4})-(\d{1,2})-(\d{1,2}).*/, '\3-\2-\1')
  end

  def send_email
    data = Multimap.new
    data[:from] = "Guillaume <user@organizedbeer.mailgun.org>"  #This will be the from, make sure to have your provided email address in <>
    data[:to] = "#{@user.email}"
    data[:subject] = "Craigslist Digest - #{Time.now.month}/#{Time.now.day}/#{Time.now.year}"
    data[:text] = generate_email_body
    RestClient.post "https://api:key-2vry40wfv2ptvmzp-4hb1mpt1uzxesb9"\
    "@api.mailgun.net/v2/organizedbeer.mailgun.org/messages", data
  end

end