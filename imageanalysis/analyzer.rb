#! /usr/bin/env ruby

require 'RMagick'
require 'optparse'
require 'json'
require 'fileutils'

class ColorAnalyzer
	attr_accessor :aggregate, :reference_aggregate

	###
	# + num_colors : the number of colors to reduce the image to
	# + colorspace : the colorspace to quantize in (default - HSL)
	###
	def initialize(num_colors, colorspace=Magick::RGBColorspace) 
		@num_colors = num_colors
		@colorspace = colorspace
		@aggregate = {:hues => {}, :total_hue_count => 0}
		@reference_aggregate = {:hues => {}, :total_hue_count => 0}
	end

	###
	# Given a histogram of colors to frequencies, adds to a running aggregate
	# of the frequency of specific colors, in HLSA
	###
	def aggregate_colors(color_histogram)
		color_histogram.each do |pixel, count|
			# We convert to HSLA to easily draw an ordered gradient.
			# Hue is between 0 and 360. 
			# Saturation and lightness are between 0 and 255.
			hue, sat, light = pixel.to_hsla
			hue = hue.round # Round the hue for looser aggregation
			hue = hue == 360 ? 0 : hue

			# Calculate a reference hue for a simple percentage calculation
			# Note: 360 deg == 0 deg == 'red'
			reference_hue = (hue / 30).round * 30
			reference_hue = reference_hue == 360 ? 0 : reference_hue 

			light_percent = light / 255.0
			sat_percent = sat / 255.0

			isWhite = light_percent > 0.99
			isBlack = sat_percent < 0.01
			isGrey = (0.01 < light_percent && light_percent < 0.03) || sat_percent < 0.05

			# Avoid pure white and black colors when calculating
			# aggregate frequency for a more colorful output
			unless isWhite || isBlack || isGrey
				if @aggregate[:hues][hue] != nil
					@aggregate[:hues][hue][:total_light] += light
					@aggregate[:hues][hue][:total_sat] += sat
					@aggregate[:hues][hue][:count] += count
				else 
					@aggregate[:hues][hue] = {
						:total_light => light, 
						:total_sat => sat, 
						:count => count
					}
				end
			end

			# Keep track of reference hues for a simple percentage calculation
			if @reference_aggregate[:hues][reference_hue] != nil
				@reference_aggregate[:hues][reference_hue][:count] += count
			else
				@reference_aggregate[:hues][reference_hue] = {
					:count => count
				}
			end
		end

		full_count = total_hue_count(@aggregate)
		ref_count = total_hue_count(@reference_aggregate)

		@aggregate[:total_hue_count] = full_count
		@reference_aggregate[:total_hue_count] = ref_count

		@aggregate[:hues].each do |hue, info|
			percentage = info[:count] / full_count.to_f
			@aggregate[:hues][hue][:percentage] = percentage 
		end

		@reference_aggregate[:hues].each do |hue, info|
			percentage = info[:count] / ref_count.to_f
			@reference_aggregate[:hues][hue][:percentage] = percentage 
		end

		@aggregate[:total_hue_count] = full_count
		@reference_aggregate[:total_hue_count] = ref_count

	end

	###
	# Loads a new image into the running aggregate
	###
	def aggregate_image(image)
		# For faster processing, we reduce the image to @num_colors 
		# and calculate the color histogam from there
		quantized_image = image.quantize(@num_colors, @colorspace)
		color_histogram = quantized_image.color_histogram

		self.aggregate_colors(color_histogram)
	end

	def total_hue_count(aggregate)
		total_hue_count = 0
		aggregate[:hues].each do |hue, info|
			total_hue_count += info[:count]
		end

		return total_hue_count
	end

end


def loadImage(image_path)
	# We're only reading single-frame images so always get the first one
	return Magick::Image.read(image_path).first
end


if __FILE__ == $PROGRAM_NAME
	options = {}

	optparse = OptionParser.new do |opts|
		opts.banner = "Usage: analyzer.rb [options] --dir DIRECTORY -o OUTPUT_DIR"

   		opts.on( '-d', '--dir DIRECTORY', 'Top-level directory containing sub-directories of images', 'e.g. the city directory') do |dir|
   			options[:dir] = dir
   		end

   		opts.on( '-o', '--output OUTPUT_DIR', 'Output directory') do |dir|
   			options[:output] = dir
   		end

   		opts.on( '-s', '--sample-size N', 'Sample N percent of images. NOTE: Right now only gets first N percent') do |n|
   			options[:sample] = n.to_i
   		end

   		opts.on( '-v', '--verbose', 'Does nothing right now' ) do
     		options[:verbose] = true
   		end

		opts.on( '-h', '--help', 'Display this screen' ) do
			puts opts
			exit
		end
	end

	optparse.parse!
	dir = options[:dir]
	out = options[:output]

	if dir.nil? || out.nil?
		puts "Missing either directory or output file switch"
		puts optparse
		exit
	else

		unless File.directory?(out)
			FileUtils.mkdir_p(out)
		end

		month_dirs = Dir.glob("#{dir}/**").map do |path|
			path.split('/').last
		end

		month_dirs.each do |month|
			puts "Processing images for #{month}"
			analyzer = ColorAnalyzer.new(384)
			images = Dir.glob("#{dir}/#{month}/*.jpg")
			processed = 0

			images.each do |f|
				if File.file?(f) && File.size?(f)
					image = loadImage(f)
					analyzer.aggregate_image(image)					
				end	

				processed += 1
				progress = ((processed / images.length.to_f) * 100).to_i
				
				print "\r#{progress}%"
				sample = options[:sample]
				if sample != nil && progress >= sample
					break
				end
			end

			relative_path = "#{out}/#{month}.json"
			path = File.expand_path(relative_path)

			File.open(path, 'w') do |f|

				output = {
					:aggregate => analyzer.aggregate, 
					:ref_aggregate => analyzer.reference_aggregate 
				}

				JSON.dump(output, f)
			end

			puts "\n"
		end

		puts "Output can be found at #{File.expand_path(out)}"

	end
end








