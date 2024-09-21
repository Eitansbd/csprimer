def middle_of_multi_byte_sequence?(byte)
    # in UTF-8, 1 byte characters have the form 0xxxxxxx, and multi-byte characters start
    # with 1's indicating the length of the sequence (either 110.., 1110.., 11110..). Bytes in the middle
    # of a sequence always start with 10xxxxxx, so we can check if a byte is in the middle of a sequence
    byte & 0xC0 == 0x80
end

def truncate(data, length)
    return data if length > data.length

    # if the next byte is the middle of a sequence, that means the current byte is either the beginning or the middle
    # of a multi-byte sequence and should be truncated. data[length] will give us the "next byte" b/c of 0-based indexing
    length -= 1 while middle_of_multi_byte_sequence?(data[length])

    data[0, length]
end

File.open('result', 'wb') do |result_file|
    File.readlines('cases').each do |line|
        bytes = line.unpack('C*')
        truncation_length = bytes[0]

        truncated = truncate(bytes[1...-1], truncation_length)
        truncated << 0x0a

        result_file.write(truncated.pack('C*'))
    end
end
