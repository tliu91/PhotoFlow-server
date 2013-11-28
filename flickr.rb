#! /usr/bin/env ruby

require 'rest_client'
require 'json'
require 'date'

@base_url = 'http://api.flickr.com/services/rest/'

def get_all_photos()
	cities = [ 	{:name => 'Los Angeles', :lat => 34.098159, :lon => -118.243532}, 
				{:name => 'Houston', :lat => 29.787025, :lon => -95.369782}, 
				{:name => 'Washington, D.C', :lat => 38.918819, :lon => -77.036927},
				{:name => 'Chicago', :lat => 41.902277, :lon => -87.634034},
				{:name => 'Minneapolis', :lat => 44.995397, :lon => -93.265107},
				{:name => 'Seattle', :lat => 44.995397, :lon => -93.265107}
	]

	starting_year = 2011
	ending_year = 2013


	cities.each do |city|

		puts "*"*60
		puts "*"*60
		puts "----CITY: #{city[:name]}"
		puts "*"*60
		puts "*"*60

		(starting_year..ending_year).each do |year|
			12.times do |month| 
				month += 1
				start_date = Date.new(year, month, 1)
				end_date = Date.new(year, month, -1)	

				get_photos(city[:lat], city[:lon], start_date, end_date)
			end
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
	api_key = '28698c60ea6da45e56e1b991cce417b3'

	min_taken_date = start_date
	max_taken_date = end_date

	per_page = 500 # for geospatial queries, this does nothing as those requests are limited to 250 per page

	max_page = 10

	max_page.times do |page|

		puts page + 1

		query = "?method=#{method}&format=#{format}&nojsoncallback=1&api_key=#{api_key}&page=#{page+1}&min_taken_date=#{min_taken_date}&max_taken_date=#{max_taken_date}&per_page=500&lat=#{lat}&lon=#{lon}"
		url = "#{@base_url}#{query}"

		begin
			results = RestClient.get(url)
		rescue => e
			puts e.response
			puts "!"*100
			puts "EXCEPTION for page #{page+1} for month #{start_date}"
			puts "!"*100
			next
		end

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
get_all_photos()
