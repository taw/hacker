#!/usr/bin/env ruby

def calc(num)
  num1 = 0
  (0...num).each do |indexn|
    sn = indexn.to_s.size
    num1 += sn * (num**4) * 5
  end
  num1 += 16 * (num**5)
  num1 &= 0xFFFF_FFFF
  num1 = [num1].pack("V").unpack("l")[0]
  num1
end

num = 99
i = num
while i >= 0
  puts i
  puts "val: #{calc(num - i)}"
  i -= 1
end
