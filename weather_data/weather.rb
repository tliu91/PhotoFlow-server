#! /usr/bin/env ruby

require 'csv'
require 'json'

filename = "seattle.csv"

# Key is the column to check, value is what to match

options = { :headers      =>  :first_row,
            :converters   =>  [ :numeric ] }

data = {}

CSV.open( filename, "r", options ) do |csv|
	csv.each do |row|
		date = Date.parse(row[0])
		month = date.month

		if data[month].nil?
			data[month] = row[2] # mean temperature
		else
			data[month] += row[2]
		end
	end
end

data.each do |month, temp|
	days_in_month = Date.new(2011, month, -1).day
	data[month] = data[month] / days_in_month
end

puts JSON.dump(data)



