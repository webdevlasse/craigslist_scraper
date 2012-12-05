require_relative './lib/craigslist.rb'

session = CraigslistUI.new('beer.db')
session.start_organized_beer