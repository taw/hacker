#!/usr/bin/env ruby

require "pp"

# k = {unknown 4-byte value}
# x = {unknown 4-byte value}
# m = {unknown 4-byte value}
# for (i = 0; i < len(txt); i += 4)
#   c = (txt[i] -> txt[i + 3]) ^ k
#   print c
#   k = (c * m + x) % 0x100000000


data = "d1b4a39d62c71e3448d820aa0021cc744e4c7e401cdb5fcb2a76912fc1926aed3ab2bce8a64bfe9a85018980789a1d8f5bee4e7d0f091e5c05fb3e0aff14423405115d9fe4ed2d34298ec36a7f3799c8be83a4f3647de6bbe8b3cd2aa20406b39ba7b57a417ce746fb031a47b40e"

data = data.scan(/../).map{|x| x.to_i(16).chr}.join

def encryption(k, x, m, data)
  crypto = ""
  (0...data.size).step(4) {|i|
    c = data[i, 4].unpack("V")[0] ^ k
    crypto << [c].pack("V")
    k = (c * m + x) % 0x1_0000_0000
  }
  crypto
end

def decryption(k, x, m, data)
  plain = ""
  (0...data.size).step(4) {|i|
    c = data[i, 4].unpack("V")[0]
    break if c.nil?
    p = c ^ k
    # pp [:decoding, k, x, c, p]
    k = (c * m + x) % 0x100000000
    plain << [p].pack("V")
  }
  plain
end


def test
  x = 12345456
  k = 563465365
  m = 479723234
  plain = "Cats are so totally awesome!"
  crypto = encryption(k, x, m, plain)
  plain2 = decryption(k, x, m, crypto)
  puts plain2
end

# test


k = 0
x0 = 0x2b
x1 = 0xaf
x2 = 0xfb
m0 = 0xaf
m1 = 0xd8
m2 = 0xaa

(0..0xff).each{|x3|
  (0..0xff).each{|m3|

    x = x0 + 0x100 * x1 + 0x10000 * x2 + 0x1000000 * x3
    m = m0 + 0x100 * m1 + 0x10000 * m2 + 0x1000000 * m3

    out = decryption(k, x, m, data)
    outc = out.unpack("C*")
    sample = (4...data.size).map{|j| next if j % 4 > 3; outc[j]}.compact
    next if sample.any?{|c| c > 128}
    p ["%02x" % x, "%02x" % m, "%02x" % k, sample.map(&:chr).join]
  }
}
