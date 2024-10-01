# prompt: Write two functions conceal and extract,
# such that: conceal can be invoked with a short string (hint: as many as 6 bytes)
# and the returned value is and behaves identically to a NaN.
# However, invoking extract with that same value reveals the original message

# single precision floats use 64 bits (8 bytes)
# 1 sign bit, 11 exponent bits and 52 fraction bits
# NAN is when all the exponents are "on" and ANY fraction is on.
# The exponent bits obviously all need to be on. Of the fraction bits,
# we can turn on the first one to make it a NAN. We now have 51 bits left
# to encode a message. That's 6 bytes and 3 bits, with the 3 bits as part
# of the exponent bytes. We can encode the length of the message in those
# 3 bits, and then the message in the remaining 6 bytes.

def conceal(message)
    # Force the message to be in ascii so that we can get the byte length
    # and not just the unicode length.
    message = message.force_encoding('ASCII-8BIT')
    message_length = message.length

    raise 'message too long' if message_length > 6

    # double precision NAN with the first fraction on has following bytes 0x7fxf8\x00\x00\x00\x00\x00\x00
    (
        [0x7f, 0xf8 | message_length].pack('CC') + # exponent portion all "on" | encoding length into lower 3 bits
        ("\x00" * (6 - message_length)) + # add padding to maintain NaN format
        message
    ).unpack1('G')
end

def extract(nan)
    # the NaN is a float class, so we need to convert it to a the byte representation
    # as a string and then convert it to an array of bytes
    bytes = [nan].pack('G').unpack('C*')

    # get the length from the lower 3 bits of the second byte
    message_length = bytes[1] & 0b111

    # we know how long the message is and that it's at the end of the bytes.
    # also, pack will convert the array of bytes to an ascii string, which is
    # a problem if we're trying to encode something like an emoji in UTF-8
    bytes[-message_length..].pack('C*').force_encoding('UTF-8')
end

def test(message)
    sneeky_nan = conceal(message)
    decoded_message = extract(sneeky_nan)
    raise 'not a nan' unless sneeky_nan.nan?
    raise 'decoded message incorrect' unless decoded_message == message
end

['ABCDEF', 'Super', 'a', '🤠!'].each do |message|
    test(message)
    puts "message: #{message} passed"
end
