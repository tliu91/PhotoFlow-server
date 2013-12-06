#!/usr/bin/env ruby
require 'rest_client'
require 'fileutils'
require 'optparse'
require 'mongo'
require 'json'

options = {}
optparser = OptionParser.new do |opt|
	opt.banner = "Usage: download.rb city [options]"

	options[:exact] = false
	opt.on("-e", "--exact", "use exact lat/long, default to bounding box") do
		options[:exact] = true
	end

	opt.on("-h", "--help", "help") do
		puts optparser
		exit
	end
end
optparser.parse!

bbox = !options[:exact]
city = ARGV[0]

if city.nil?
	abort("Must specify a city.")
end

base_folder = "data"
folder = bbox ? "lat-long-bbox" : "lat-long-exact"

@base_url = 'http://api.flickr.com/services/rest/'
@api_key = '28698c60ea6da45e56e1b991cce417b3'
@format = 'json'

def get_photo_geo(photo_id)
	method = 'flickr.photos.geo.getLocation'

	query = "?method=#{method}&format=#{@format}&nojsoncallback=1&api_key=#{@api_key}&photo_id=#{photo_id}"
	url = "#{@base_url}#{query}"

	begin
		results = RestClient.get(url)
	rescue => e
		puts e.response
		puts "!"*100
		puts "EXCEPTION for getting photo geo of #{photo_id}"
		puts "!"*100
		return nil
	end

	parsed = JSON.parse(results)
	return parsed
end

def deconstruct_photo_url(url)
	if match = url.match(/http:\/\/farm(.*)\.staticflickr.com\/(.*)\/(.*)_(.*)\.jpg/i)
		farm, server, id, secret = match.captures

		return {
			:farm => farm,
			:server => server,
			:id => id,
			:secret => secret
		}
	end

	nil
end

client = Mongo::MongoClient.new
db     = client['photoflow']
coll   = db[city]

start_date = ''
end_date = ''

File.open("#{base_folder}/#{folder}/#{city}_data.txt", 'r').each_line do |line|
	unless /^http/.match(line)
		data = line.split(',')
		start_date = data[0]
		end_date = data[1]
		puts start_date + ' ' + end_date
	else
		url = /(.*).jpg/.match(line)[0]
		photo = deconstruct_photo_url(url)

		if coll.find('id' => photo[:id]).count() >= 1
			puts photo[:id] + ' already exists'
			next
		end

		geo = get_photo_geo(photo[:id])

		begin
			geo = geo.nil? ? nil : geo['photo']['location']
		rescue => e
			puts 'CANT FIND GEO'
			next
		end

		coll.insert({
			:id => photo[:id],
			:secret => photo[:secret],
			:farm => photo[:farm],
			:server => photo[:server],
			:url => url,
			:location => geo,
			:start_date => start_date.gsub("\n", ''),
			:end_date => end_date.gsub("\n", '')
		})

	end
end
