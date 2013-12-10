require 'foursquare2'
require 'optparse'

options = {}
optparser = OptionParser.new do |opt|
	opt.banner = "Usage: foursq.rb [options]"

	options[:city] = nil
	opt.on("-c", "--city city", "which city to pull stuff from") do |city|
		options[:city] = city.to_sym
	end

	options[:output] = 'data.csv'
	opt.on("-o", "--output file", "where to export the csv") do |file|
		options[:output] = file
	end

	opt.on("-h", "--help", "help") do
		puts optparser
		exit
	end
end
optparser.parse!

cities = {
	:la           => { :lat => 34.098159, :lon => -118.243532, :ne_lat => 34.33926,  :ne_lon => -117.929466, :sw_lat => 33.694679, :sw_lon => -118.723549 },
	:houston      => { :lat => 29.787025, :lon => -95.369782,  :ne_lat => 30.236691, :ne_lon => -94.943367,  :sw_lat => 29.39027,  :sw_lon => -95.893944 },
	:dc           => { :lat => 38.918819, :lon => -77.036927,  :ne_lat => 39.00375,  :ne_lon => -76.904503,  :sw_lat => 38.799461, :sw_lon => -77.147057 },
	:chicago      => { :lat => 41.902277, :lon => -87.634034,  :ne_lat => 42.07436,  :ne_lon => -87.397217,  :sw_lat => 41.624851, :sw_lon => -87.968437 },
	:seattle      => { :lat => 44.995397, :lon => -93.265107,  :ne_lat => 47.745071, :ne_lon => -122.176193, :sw_lat => 47.422359, :sw_lon => -122.472153 },
	:boston       => { :lat => 42.372242, :lon => -71.060364,  :ne_lat => 42.397259, :ne_lon => -70.923042,  :sw_lat => 42.227859, :sw_lon => -71.191208 },
	:minneapolis  => { :lat => 44.995397, :lon => -93.265107,  :ne_lat => 45.051281, :ne_lon => -93.193741,  :sw_lat => 44.89024,  :sw_lon => -93.329147 },
}

if not cities.has_key?(options[:city])
	abort("Must specify a valid city.")
end

@city = cities[options[:city]]
@foursq = Foursquare2::Client.new(
	:api_version => '20131209',
	:client_id => 'QMYWFEROVMWFSI4DO3XL3WVLKJAUWC30FLLFEKQDYMEUOYVA',
	:client_secret => 'WLYC1PY230FN422YLBTHD35IE2HUG4OJBTJHUKMJ2G3OGIAH'
)

def flatten_categories_tree(category)
	results = [category]
	unless category['categories'].nil?
		category['categories'].each do |subcategory|
			results += flatten_categories_tree(subcategory)
		end
	end
	results
end

def get_all_subcategories(name)
	categories = []
	@foursq.venue_categories.each do |category|
		if category['shortName'] == name then
			categories += flatten_categories_tree(category)
		end
	end
	categories
end

category_ids = get_all_subcategories('Outdoors & Recreation').map { |cat| cat['id'] }
category_ids_str = category_ids.join(',')

venues = @foursq.search_venues({
	:intent => 'browse',
	:sw => "#{@city[:sw_lat]},#{@city[:sw_lon]}",
	:ne => "#{@city[:ne_lat]},#{@city[:ne_lon]}",
	:categoryId => category_ids_str
})

file = File.open(options[:output], 'w')
file.write("NAME,TYPE,LAT,LONG\n")
venues['venues'].each do |venue|
	name = venue['name']
	lat = venue['location']['lat']
	lng = venue['location']['lng']
	cat = venue['categories'][0]['shortName']
	file.write("#{name},#{cat},#{lat},#{lng}\n")
end
