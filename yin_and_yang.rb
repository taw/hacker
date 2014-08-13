#!/usr/bin/env ruby

require "pp"

ax = File.read("m1.pnm")
bx = File.read("m2.pnm")

a = ax[11..-1].unpack("C*")
b = bx[11..-1].unpack("C*")

puts ax[0,11]
print a.zip(b).map{|i,j| i^j}.pack("C*")
