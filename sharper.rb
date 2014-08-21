#!/usr/bin/env ruby

def calc(num)
  num1 = 0
  (0...num).each do |index1|
    s1 = index1.to_s.size
    (0...num).each do |index2|
      s2 = index2.to_s.size
      (0...num).each do |index3|
        s3 = index3.to_s.size
        (0...num).each do |index4|
          s4 = index4.to_s.size
          (0...num).each do |index5|
            s5 = index5.to_s.size
            num1 += s1 + s2 + s3 + s4 + s5 + 16
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
