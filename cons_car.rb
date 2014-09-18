#!/usr/bin/env ruby

def nearest_pow(x)
  2 ** x.to_s(2).size
end

def result(x)
  x*2 - nearest_pow(x)
end

puts result(123456789)
