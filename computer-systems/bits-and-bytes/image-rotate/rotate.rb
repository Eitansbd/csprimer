# See https://en.wikipedia.org/wiki/BMP_file_format for an explanation of the BMP file format.
# Rotate the teapot.bmp file 90 degrees counter-clockwise.

# keep in mind that there are 3 bytes per pixel (BGR)
def rotate_pixels(original_pixels, width, height)
    rotated = []
    width.times do |y|
        height.times do |x|
            original_y = x
            original_x = width - y - 1
            original_location = 3 * ((original_y * width) + original_x)

            rotated << original_pixels[original_location, 3]
        end
    end

    rotated.join
end

File.open('teapot.bmp', 'rb') do |f|
    data = f.read.b
    # The first two bytes should be 'BM' to show it's a bitmap
    file_format_check = data[0, 2]
    puts file_format_check

    # The offset is 10 bytes into the file, and is 4 bytes long, little endian
    offset = data[0x0A, 4].unpack1('l<')
    # The height and with are at 18 and 22 bytes into the file,
    # and are each 4 bytes long, little endian
    height = data[0x12, 4].unpack1('l<')
    width = data[0x16, 4].unpack1('l<')

    File.open('rotated.bmp', 'wb') do |f|
        # because we're assuming square we don't need to change width / height
        headers = data[0...offset]
        pixels = rotate_pixels(data[offset..], width, height)

        f.write(headers + pixels)
    end
end
