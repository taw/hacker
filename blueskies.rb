#!/usr/bin/env ruby

r_raw = []
open("blueskies.pnm").read[15..-1].unpack("C*").each_slice(3){|r,g,b| r_raw << r }
r_raw.each_slice(250){|x| puts x.join }
