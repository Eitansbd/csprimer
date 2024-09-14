# write an encode function which takes an unsigned 64 bit integer and returns a
# sequence of bytes in the varint encoding that Protocol Buffers uses.
# You should also write a decode function which does the inverse.

def encode(uint64)
    # take the first 7 bits of the number (we can use a mask of 0x7F to get the first 7 bits)
    # then shift the number 7 bits to the right. See if that is > 0. If it is, turn the 8th bit on
    # using | 0x80, then repeat unit the number is not > 0.

    bytes = []
    loop do
        # take the lowest 7 bits of the number
        byte = (uint64 & 0x7F)
        # shift the number to the right by 7 bits to continue processing
        uint64 >>= 7
        # if after shifting the number is > 0, there are more bits to process
        if uint64 > 0
            # because there are more bytes to process, turn on the MSB (most significant bit) before adding the byte
            bytes << (byte | 0x80)
        else
            # if there are no more bytes to process, add the byte without the MSB turned on and break the loop
            bytes << byte
            break
        end
    end

    # pack the array of bytes into a string of 8 bit unsigned ints (ie a byte)
    bytes.pack('C*')
end

def decode(varint)
    int = 0
    # The bits are stored in little endian order, so we need to reverse the array to process the highest bits first
    varint.unpack('C*').reverse_each do |byte|
        # shift the int to the left by 7 bits to make room for the next 7 bits
        int <<= 7
        # add the 7 lower bits to the int, this drops the MSB
        int |= byte & 0x7f
    end
    int
end

[['1.uint64', "\x01".b],
 ['150.uint64', "\x96\x01".b],
 ['255.uint64', "\xFF\x01".b]].each do |file, expected_result|
    raw_uint64 = File.read(file).unpack1('Q>')
    encoded = encode(raw_uint64)
    puts encoded == expected_result
    puts raw_uint64 == decode(encoded)
end
