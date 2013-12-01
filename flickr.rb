#! /usr/bin/env ruby

require 'rest_client'
require 'json'
require 'date'

@base_url = 'http://api.flickr.com/services/rest/'

def get_all_photos(bbox = false)
	cities = {
		:la           => { :lat => 34.098159, :lon => -118.243532, :ne_lat => 34.33926,  :ne_lon => -117.929466, :sw_lat => 33.694679, :sw_lon => -118.723549 },
		:houston      => { :lat => 29.787025, :lon => -95.369782,  :ne_lat => 30.236691, :ne_lon => -94.943367,  :sw_lat => 29.39027,  :sw_lon => -95.893944 },
		:dc           => { :lat => 38.918819, :lon => -77.036927,  :ne_lat => 39.00375,  :ne_lon => -76.904503,  :sw_lat => 38.799461, :sw_lon => -77.147057 },
		:chicago      => { :lat => 41.902277, :lon => -87.634034,  :ne_lat => 42.07436,  :ne_lon => -87.397217,  :sw_lat => 41.624851, :sw_lon => 87.968437 },
		:seattle      => { :lat => 44.995397, :lon => -93.265107,  :ne_lat => 47.745071, :ne_lon => -122.176193, :sw_lat => 47.422359, :sw_lon => -122.472153 },
		:boston       => { :lat => 42.372242, :lon => -71.060364,  :ne_lat => 42.397259, :ne_lon => -70.923042,  :sw_lat => 42.227859, :sw_lon => -71.191208 },
		:minneapolis  => { :lat => 44.995397, :lon => -93.265107,  :ne_lat => 45.051281, :ne_lon => -93.193741,  :sw_lat => 44.89024,  :sw_lon => -93.329147 },
	}

	starting_year = 2011
	ending_year = 2013

	cities.each do |name, city|

		puts "*"*60
		puts "*"*60
		puts "----CITY: #{name}"
		puts "*"*60
		puts "*"*60

		folder = bbox ? "lat-long-bbox" : "lat-long-exact"
		filename = "data/#{folder}/#{name}_data.txt"
		file = File.open(filename, "w")

		(starting_year..ending_year).each do |year|
			12.times do |month|
				month += 1
				start_date = Date.new(year, month, 1)
				end_date = Date.new(year, month, -1)

				get_photos(city, start_date, end_date, file)
			end
		end

		file.close unless file == nil
	end
end

def get_photos(city, start_date, end_date, file, bbox = false)

	if bbox
		lat = city[:lat]
		lon = city[:lon]
		geo = "&lat=#{lat}&lon=#{lon}"
	else
		geo = "&bbox=#{city[:sw_lon]},#{city[:sw_lat]},#{city[:ne_lon]},#{city[:ne_lat]}"
	end

	puts "-"*60
	puts "-"*60
	puts "-----Getting photos between #{start_date} and #{end_date}"
	puts "-"*60
	puts "-"*60
	file.write("#{start_date}, #{end_date}\n")

	method = 'flickr.photos.search'
	format = 'json'
	api_key = '28698c60ea6da45e56e1b991cce417b3'

	min_taken_date = start_date
	max_taken_date = end_date

	per_page = 250 # for geospatial queries, this does nothing as those requests are limited to 250 per page
	max_page = 10

	max_page.times do |page|

		puts "Page #{page + 1}"

		query = "?method=#{method}&format=#{format}&nojsoncallback=1&api_key=#{api_key}&page=#{page+1}&min_taken_date=#{min_taken_date}&max_taken_date=#{max_taken_date}&per_page=#{per_page}#{geo}"
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
			file.write("#{photo_url}\n")
			flickr_urls << photo_url
		end

		puts flickr_urls.length
	end
end

def construct_photo_url(dict)
	farm = dict["farm"]
	server = dict["server"]
	id = dict["id"]
	secret = dict["secret"]

	return "http://farm#{farm}.staticflickr.com/#{server}/#{id}_#{secret}.jpg"
end

get_all_photos(true)
