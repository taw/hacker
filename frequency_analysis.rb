#!/usr/bin/env ruby

require "pathname"
require "complex"
require "pp"

def analyze!(data)
  # puts "Sample size is #{data.size}"
  power_by_freq = Hash[(1..1000).map do |freq|
    re = 0.0
    im = 0.0
    data.each_with_index do |v,i|
      t = (i.to_f/44100) # time in seconds
      re += v * Math::sin(2*Math::PI * t * freq)
      im += v * Math::cos(2*Math::PI * t * freq)
    end
    power = Math.sqrt(re**2 + im**2) / data.size
    [freq, power.round(2)]
  end]
  puts "Peak frequency is: #{power_by_freq.to_a.max_by{|f,p| p}.inspect}"
end

# sox -c 1 -b 16 -e signed melodic.mp3 melodic.raw

audio_file = ARGV[0]
data = Pathname(audio_file).read.unpack("s*")

100.times do |i|
  part = data[data.size*i/100, data.size/100]
  analyze! part
end

# feed a bad beef
# 350  F
# 660  E
# 330  E
# 294  D
# 220  A
# 248  B
# 439  A
# 293  D
# 249  B
# 330  E
# 660  E
# 351  F
