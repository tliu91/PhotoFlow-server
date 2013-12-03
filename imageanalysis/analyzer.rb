require 'RMagick'

class ColorAnalyzer

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
			# We convert to HSLA to easily draw an ordered gradient
			# which is our ultimate goal
			hue, sat, light = pixel.to_hsla
			hue = hue.round # Round the hue for looser aggregation

			# Calculate a reference hue for a simple percentage calculation
			reference_hue = (hue / 30).round * 30
			# 360 deg. == 0 deg. == 'red'
			reference_hue = reference_hue == 360 ? 0 : reference_hue 

			isWhite = light >= 0.99
			isBlack = light <= 0.01

			# Avoid pure white and black colors 
			# when calculating aggregate frequency
			# for we want a more colorful output
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






