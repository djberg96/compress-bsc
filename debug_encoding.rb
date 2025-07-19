require_relative 'lib/ffi_bsc'

puts "Testing encoding preservation..."
FFI_BSC.init

# Test each data type
test_cases = [
  "Simple ASCII text",
  "Unicode text: 你好世界 🌍",
  "\x00\x01\x02\x03" * 100,
  "A" * 10000,
  Random.bytes(1000),
  "Mixed\x00data\xFF\x80with\x01binary"
]

test_cases.each_with_index do |data, index|
  puts "\n--- Test case #{index + 1} ---"
  puts "Original encoding: #{data.encoding}"
  puts "Original bytes (first 10): #{data.bytes[0, 10]}"

  compressed = FFI_BSC.compress(data)
  puts "Compressed size: #{compressed.bytesize}"

  decompressed = FFI_BSC.decompress(compressed)
  puts "Decompressed encoding: #{decompressed.encoding}"
  puts "Decompressed bytes (first 10): #{decompressed.bytes[0, 10]}"

  puts "Content equal: #{data == decompressed}"
  puts "Encoding equal: #{data.encoding == decompressed.encoding}"
  puts "Bytes equal: #{data.bytes == decompressed.bytes}"
end
