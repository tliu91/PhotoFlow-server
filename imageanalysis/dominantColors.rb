require 'RMagick'
 
TOP_N = 256   # Number of swatches
 
# Create a 1-row image that has a column for every color in the quantized
# image. The columns are sorted by decreasing frequency of appearance in the
# quantized image.
def sort_by_decreasing_frequency(img)
  hist = img.color_histogram
  # sort by decreasing frequency
  sorted = hist.keys.sort_by {|p| -hist[p]}
  sorted = sorted * 100
  new_img = Magick::Image.new(hist.size, 100)
  new_img.store_pixels(0, 0, hist.size, 100, sorted)
end

def average_color(quantized)
  total = 0
  avg = { :r => 0.0, :g => 0.0, :b => 0.0 }

  quantized.color_histogram.each do |c,n|
    avg[:r] += n * c.red
    avg[:g] += n * c.green
    avg[:b] += n * c.blue
    total += n
  end

  avg.each_key do |c| 
    avg[c] /= total
    avg[c] = (avg[c] / Magick::QuantumRange * 255).to_i
  end

  avg_color = "rgb(#{avg[:r]},#{avg[:g]},#{avg[:b]})"
  avg_image = Magick::Image.new(100, 100)

  canvas = Magick::Draw.new()
  canvas.fill(avg_color)
  canvas.rectangle(0, 0, 100, 100)
  canvas.draw(avg_image)

  avg_image
end
 
original = Magick::Image.read("/Users/fsosa/Dev/PhotoFlow-server/images/lat-long-bbox/la/2011-03-01/5608490071_37ac2fef3b.jpg").first
 
# reduce number of colors
quantized = original.quantize(TOP_N, Magick::HSLColorspace)

# Create an image that has 1 pixel for each of the TOP_N colors.
normal = sort_by_decreasing_frequency(quantized)
avg_color = average_color(quantized)

original.write("original.png")
quantized.write("quantized_#{TOP_N}.png")
normal.write("normalized_#{TOP_N}.png")
avg_color.write("avg_color_#{TOP_N}.png")







