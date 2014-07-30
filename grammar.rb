#!/usr/bin/env ruby

str = "S"

while str =~ /[A-S]/
  str.gsub! "A", "is"
  str.gsub! "B", "mm"
  str.gsub! "C", "oo"
  str.gsub! "D", "rgr"
  str.gsub! "E", "ryg"
  str.gsub! "F", "dth"
  str.gsub! "G", "you"
  str.gsub! "H", "esol"
  str.gsub! "I", "ionA"
  str.gsub! "J", "GDaBarA"
  str.gsub! "K", "veECFHutI"
  str.gsub! "L", "PQ"
  str.gsub! "M", "n"
  str.gsub! "N", "m"
  str.gsub! "O", "oaNcho"
  str.gsub! "P", "MO"
  str.gsub! "Q", "NR"
  str.gsub! "R", "sky"
  str.gsub! "S", "JKL"
end

puts str
