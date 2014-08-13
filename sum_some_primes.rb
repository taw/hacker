#!/usr/bin/env ruby

require "gmp"

a=49_999_951
b=50_000_000
e=GMP::Z.new("0")
x=GMP::Z.new("1")
a.times{|i| p i if i % 10000 == 0;  x.next_prime! }
(a..b).each{ e += x; x.next_prime! }
puts e
