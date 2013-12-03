require 'RMagick'

class ColorAnalyzer

	def initialize(num_colors, colorspace)
		@num_colors = num_colors
		@colorspace = colorspace
		@aggregate = {}
	end

	###
	# Given a histogram of colors to frequencies, adds to a running aggregate
	# of the frequency of specific colors, in terms of HLSA hue
	###
	def aggregate_colors(color_histogram)
		color_histogram.each do |pixel, count|
			# We convert to HSLA b/c it's easier to draw a rainbow gradient
			# which is our ultimate goal
			hue, sat, light = pixel.to_hsla 

			isWhite = light >= 0.99
			isBlack = light <= 0.01

			# Avoid pure white and black colors 
			# when calculating aggregate frequency
			unless isWhite || isBlack
				

			end


		end
	end

	###
	# Loads a new image into a running aggregate
	###
	def aggregate_image(image)
		# For faster processing, we reduce the image to @num_colors 
		# and calculate the color histogam from there
		color_histogram = image.quantize(@num_colors, @colorspace)

		self.aggregate_colors(color_histogram)
	end


end


def loadImage(image_path)
	# We're only reading single-frame images so always get the first one
	return Magick::Image.read(image_path).first
end






