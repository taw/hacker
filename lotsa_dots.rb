#!/usr/bin/env ruby

system "mv #{ENV['HOME']}/Downloads/stars.php stars.png"
system 'convert -geometry "6.25%" stars.png stars.pbm'
open("stars.pbm") do |fh|
  raise "WTF" unless fh.readline == "P4\n"
  x,y = fh.readline.chomp.split.map(&:to_i)
  raise "WTF" unless x == 8
  data = fh.read
  raise "WTF" unless y == data.size
  puts data.unpack("C*").map{|x| x^0xFF}.map(&:chr).join
end
