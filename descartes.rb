#!/usr/bin/env ruby

require "pp"

data = %W[
  0106030602040206090308030801080309
  01080110040f0613061204130113030602
  06021b031c03060607060a030b030e060e
  0417031603020302010c010c0312021103
  18061606050405060f02100118031a0311
  0311010d010d030c060c04040303030601
  060104040406030303020e031003060407
  0414041406140114030606060404050505
  060507050b010a010e030e0110020e0212
  0211011901190303010401040203020401
  0402170317011b011b0316031601110510
  04110512040d060e040d040d060b030b01
  1b011c01150115030a030a010c030d030c
  010d0116021702160616040c060b061705
  18040b050c05160518050b040b06180518
  0615061406150114031505140514041504
  1b021c0210021003
].join

svg = ""
coords = data.scan(/(..)(..)/).map{|x,y| [x.to_i(16), y.to_i(16)]}

coords.each_slice(2){|(x1,y1),(x2,y2)|
  svg << %Q[<polyline points="#{x1*20},#{y1*20},#{x2*20},#{y2*20}"/>\n]
}

# http://www.w3schools.com/svg/tryit.asp?filename=trysvg_polygon
puts %Q[
<!DOCTYPE html>
<html>
<body>
<svg height="1000" width="1000">
<g style="fill:white;stroke:red;stroke-width:3" >
#{svg}
</g>
</svg>
</body>
</html>
]