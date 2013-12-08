#!/usr/bin/env ruby
require 'optparse'
require 'csv'
require 'json'

options = {}
optparser = OptionParser.new do |opt|
	opt.banner = "Usage: csvtojson.rb [options]"

	options[:input] = nil
	opt.on("-i", "--input filename", "which filename to pull input from") do |filename|
		options[:input] = filename
	end

	options[:output] = nil
	opt.on("-o", "--output filename", "which filename to output to") do |filename|
		options[:output] = filename
	end

	options[:database] = false
	opt.on("-d", "--database", "whether to export to database") do
		options[:database] = true
	end

	opt.on("-h", "--help", "help") do
		puts optparser
		exit
	end
end
optparser.parse!

exit if options[:input].nil?

locations = []
CSV.foreach(options[:input], :headers => true) do |row|
	row['TYPE'].strip!
	type = (row['TYPE'] == '<Null>' or row['TYPE'].empty?) ? '' : row['TYPE']
	locations.push({
		:name => row['NAME'],
		:loc => [row['LONG'], row['LAT']],
		:type => type
	})
end

unless options[:output].nil?
	json = JSON.pretty_generate(locations, :indent => '  ')
	file = File.open(options[:output], 'w')
	file.write(json)
end

if options[:database]
	require 'mongo'
	client = Mongo::MongoClient.new
	db     = client['photoflow']
	coll   = db['boston_places']
	locations.each do |location|
		coll.insert(location)
	end
end
