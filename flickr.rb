#! /usr/bin/env ruby

require 'rest_client'
require 'json'
require 'date'

@base_url = 'http://api.flickr.com/services/rest/'

def get_all_photos(lat, lon)
	starting_year = 2011
	ending_year = 2013
	month = 10

	(starting_year..ending_year).each do |year|
		start_date = Date.new(year, month, 1)
		end_date = Date.new(year, month, -1)

		get_photos(lat, lon, start_date, end_date)

		month += 1
		if month > 12
			month = 1
		end
	end
end




def get_photos(lat, lon, start_date, end_date)
	puts "-"*60
	puts "-"*60
	puts "-----Getting photos between #{start_date} and #{end_date}"
	puts "-"*60
	puts "-"*60

	method = 'flickr.photos.search'
	format = 'json'
	api_key = 'SEE GOOGLE DOC'

	min_taken_date = start_date
	max_taken_date = end_date

	per_page = 500 # for geospatial queries, this does nothing as those requests are limited to 250 per page

	max_page = 10

	max_page.times do |page|

		query = "?method=#{method}&format=#{format}&nojsoncallback=1&api_key=#{api_key}&page=#{page+1}&min_taken_date=#{min_taken_date}&max_taken_date=#{max_taken_date}&per_page=500&lat=#{lat}&lon=#{lon}"
		url = "#{@base_url}#{query}"

		results = RestClient.get(url)
		parsed = JSON.parse(results)
		photos = parsed["photos"]["photo"]

		flickr_urls = []

		photos.each do |dict|
			photo_url = construct_photo_url(dict)
			flickr_urls << photo_url
		end

		puts flickr_urls
	end
end

def construct_photo_url(dict)
	farm = dict["farm"]
	server = dict["server"]
	id = dict["id"]
	secret = dict["secret"]

	return "http://farm#{farm}.staticflickr.com/#{server}/#{id}_#{secret}.jpg"
end





# Boston: 42.372242,-71.060364
get_all_photos(42.372242, -71.060364)
