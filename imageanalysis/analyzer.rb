require 'RMagick'
require 'optparse'

class ColorAnalyzer
	attr_accessor :aggregate, :reference_aggregate

	###
	# + num_colors : the number of colors to reduce the image to
	# + colorspace : the colorspace to quantize in (default - HSL)
	###
	def initialize(num_colors, colorspace=Magick::HSLColorspace) 
		@num_colors = num_colors
		@colorspace = colorspace
		@aggregate = {}
		@reference_aggregate = {}
	end

	###
	# Given a histogram of colors to frequencies, adds to a running aggregate
	# of the frequency of specific colors, in terms of HLSA hue
	###
	def aggregate_colors(color_histogram)
		color_histogram.each do |pixel, count|
			# We convert to HSLA to easily draw an ordered gradient.
			# Hue is between 0 and 360. 
			# Saturation and lightness are between 0 and 255.
			hue, sat, light = pixel.to_hsla 
			hue = hue.round # Round the hue for looser aggregation

			# Calculate a reference hue for a simple percentage calculation
			# Note: 360 deg == 0 deg == 'red'
			reference_hue = (hue / 30).round * 30
			reference_hue = reference_hue == 360 ? 0 : reference_hue 

			isWhite = light / 255.0 >= 0.99
			isBlack = light / 255.0 <= 0.01

			# Avoid pure white and black colors when calculating
			# aggregate frequency for a more colorful output
			unless isWhite || isBlack
				if @aggregate[hue] != nil
					@aggregate[hue][:total_light] += light
					@aggregate[hue][:total_sat] += sat
					@aggregate[hue][:count] += count
				else 
					@aggregate[hue] = {
						:total_light => light, 
						:total_sat => sat, 
						:count => count
					}
				end
			end

			# Keep track of reference hues for a simple percentage calculation
			if @reference_aggregate[reference_hue] != nil
				@reference_aggregate[reference_hue] += 1
			else
				@reference_aggregate[reference_hue] = 1
			end
		end
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

end


def loadImage(image_path)
	# We're only reading single-frame images so always get the first one
	return Magick::Image.read(image_path).first
end


if __FILE__ == $PROGRAM_NAME
	options = {}

	optparse = OptionParser.new do|opts|
		# Set a banner, displayed at the top of the help screen.
		opts.banner = "Usage: analyzer.rb [options] dir"

		opts.on( '-v', '--verbose', 'Output reference and full aggregates' ) do
     		options[:verbose] = true
   		end

		# This displays the help screen, all programs are
		# assumed to have this option.
		opts.on( '-h', '--help', 'Display this screen' ) do
			puts opts
			exit
		end
	end

	optparse.parse!
	dir = ARGV[0]

	if dir == nil
		exit
	else
		analyzer = ColorAnalyzer.new(1280)
		Dir.glob("#{dir}/**/*.jpg").each do |f| 
			if File.file?(f)
				x += 1
				image = loadImage(f)
				analyzer.aggregate_image(image)
			end
		end

		if options[:verbose]
			puts analyzer.aggregate
			puts "="*100
			puts analyzer.reference_aggregate
		end



	end
end








