# consume a css file and convert the hex representation of colors to rgb
require 'pry'

# mapping between hex string value to decimal value
XX_TO_DEC = '0123456789abcdef'.chars.zip(0..15).to_h

def xx_to_dec(xx)
    # xx is a two char array representing the two hex values in the byte.
    # we need to convert that to a int representing the value. Shifting
    # the first value 4 to the left can be thought of either like multiplying by 2^4 (16)
    # because when representing a byte with 2 hex digits, the 1st digit is in the 16th place, or
    # we can think of it as physically shifting the bits into the correct location

    (XX_TO_DEC[xx[0]] << 4) + XX_TO_DEC[xx[1]]
end

def convert(string)
    string.gsub(/#([0-9a-f])+/i) do |match| # we could probably do a more exact match for number of chars
        # remove '#' and downcase
        hx = match[1..].downcase
        # normalize 3/4 character form to 6/8 character form
        hx = hx.each_char.map { |c| c + c }.join if [3, 4].include?(hx.length)

        # grab two charts at a time, chars [0,1], [1,2], [3,4] and interpret each
        # of them as a byte represented in hex
        rgb = [0, 2, 4].map { |i| xx_to_dec(hx[i..i + 1]) }.join(' ')

        # if we have an opacity value
        if hx.length == 8
            # opacity is between 0 and 1, so we need to divide by 255
            opacity = (xx_to_dec(hx[6..7]) / 255.0).round(5)
            "rgba(#{rgb} / #{opacity})"
        else
            "rgb(#{rgb})"
        end
    end
end

puts convert(File.read('./simple.css')) == File.read('./simple_expected.css')
puts convert(File.read('./advanced.css')) == File.read('./advanced_expected.css')
