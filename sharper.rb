#!/usr/bin/env ruby

def calc(num)
  num1 = 0
  (0...num).each do |index1|
    (0...num).each do |index2|
      (0...num).each do |index3|
        (0...num).each do |index4|
          (0...num).each do |index5|
            str = "#{index1} to #{index2} to #{index3} to #{index4} to #{index5}"
            num1 += str.size
            num1 &= 0xFFFF_FFFF
          end
        end
      end
    end
  end
  num1
end

num = 99
i = num
while i >= 0
  puts i
  puts "val: #{calc(num - i)}"
  i -= 1
end
