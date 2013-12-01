require 'open-uri'
require 'fileutils'

bbox = true
city = 'la'

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
last_seen = 'http://farm1.staticflickr.com/999/5802898551_0000000001.jpg'
seen_last = false

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
		last_filename = /[A-Za-z\d_]+\.jpg/.match(last_seen)[0]
		if filename.eql? last_filename
			seen_last = true
		end
		
		if seen_last
		  File.open(dir + "/#{filename}", 'wb') do |fo|
		    begin	
		      fo.write(open(line).read)
		    rescue RuntimeError => e
		      next
	 	    end
		  end
		end 
	end
end
