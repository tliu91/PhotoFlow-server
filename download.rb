#!/usr/bin/env ruby
require 'open-uri'
require 'fileutils'
require 'optparse'

options = {}
optparser = OptionParser.new do |opt|
	opt.banner = "Usage: download.rb city [options]"

	options[:skipto] = nil
	opt.on("-s", "--skipto filename", "which filename to skip to") do |filename|
		options[:skipto] = filename
	end

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
last_filename = options[:skipto]
city = ARGV[0]

if city.nil?
	abort("Must specify a city.")
end

base_folder = "data"
image_base_folder = "images"
folder = bbox ? "lat-long-bbox" : "lat-long-exact"

def create_dir(some_path)
	unless File.directory?(some_path)
	  FileUtils.mkdir_p(some_path)
	end
end

start_date = ''
end_date = ''
seen_last = last_filename.nil?

File.open("#{base_folder}/#{folder}/#{city}_data.txt", 'r').each_line do |line|
	unless /^http/.match(line)
		data = line.split(',')
		start_date = data[0]
		end_date = data[1]
		puts start_date + ' ' + end_date
	else
		dir = "#{image_base_folder}/#{folder}/#{city}/#{start_date}"
		create_dir(dir)

		filename = /[A-Za-z\d_]+\.jpg/.match(line)[0]
		if not seen_last and filename.eql? last_filename
			seen_last = true
		end

		if seen_last
		  File.open(dir + "/#{filename}", 'wb') do |fo|
		    begin
		      fo.write(open(line).read)
		    rescue RuntimeError => e
		      next
		    rescue OpenURI::HTTPError
		      next
	 	    end
		  end
		end
	end
end
