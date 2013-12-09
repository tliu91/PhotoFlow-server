require 'mongo'
require 'json'

@radius = 0.0001
@results = {}

client = Mongo::MongoClient.new
db = client['photoflow']
places = db['boston_places']
photos = db['boston']

file = File.open('out/match.txt', 'w')

places.find.each do |row|
	name = row['name']
	lon = row['loc'][0].to_f
	lat = row['loc'][1].to_f
	query = {
		'start_date' => {'$regex' => /^2011/i},
		'loc' => {
			'$geoWithin' => {
				'$center' => [[lon, lat], @radius]
			}
		}
	}
	photos.find(query).each do |photo|
		if @results.has_key?(name)
			@results[name].push(photo)
		else
			@results[name] = [photo]
		end
		puts @results[name].size

		filename = /[A-Za-z\d_]+\.jpg/.match(photo['url'])[0]
		file.write("images/lat-long-bbox/boston/#{photo['start_date']}/#{filename}\n")
	end
end

json = JSON.pretty_generate(@results)
file = File.open('out/match.json', 'w')
file.write(json)
