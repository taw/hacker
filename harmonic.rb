#!/usr/bin/env ruby

require_relative "frequency_analysis"

audio_file = ARGV[0]
data = Pathname(audio_file).read.unpack("s*")

power_by_freq = analyze!(data)

power_by_freq.each do |freq, power|
  p [freq, power] if power > 5
end
