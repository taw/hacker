#!/usr/bin/env ruby

require "open-uri"
require "nokogiri"

data = Nokogiri::HTML(open("telecran.html").read)
images = data.css("img").map{|i| i["src"]}[1..-1]

countries = images.map{|i|
  {
    "img/wro.gif" => "r",
    "img/wlu.gif" => "l",
    "img/wdk.gif" => "d",
    "img/wua.gif" => "u",
  }[i]
}

polyline = []
x,y = 200, 200
countries.each do |dir|
  polyline << "#{x},#{y}"
  x += 10 if dir == "r"
  x -= 10 if dir == "l"
  y += 10 if dir == "d"
  y -= 10 if dir == "u"
end

puts %Q[
<!DOCTYPE html>
<html>
<body>

<svg height="1000" width="1000">
  <polyline points="#{polyline.join(" ")}" style="fill:white;stroke:red;stroke-width:4" />
  Sorry, your browser does not support inline SVG.
</svg>

</body>
</html>
]
