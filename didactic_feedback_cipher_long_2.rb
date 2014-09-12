#!/usr/bin/env ruby

require "pp"

# k = {unknown 4-byte value}
# x = {unknown 4-byte value}
# for (i = 0; i < len(txt); i += 4)
#   c = (txt[i] -> txt[i + 3]) ^ k
#   print c
#   k = (c + x) % 0x100000000

data = "5499fa991ee7d8da5df0b78b1cb0c18c10f09fc54bb7fdae7fcb95ace494fbae8f5d90a3c766fdd7b7399eccbf4af592f35c9dc2272be2a45e788697520febd8468c808c2e550ac92b4d28b74c16678933df0bec67a967780ffa0ce344cd2a9a2dc208dc35c26a9d658b0fd70d00648246c90cf828d72a794ea94be51bbc6995478505d37b1a6b8daf7408dbef7d7f9f76471cc6ef1076b46c911aa7e75a7ed389630c8df32b7fcb697c1e89091c30be736a4cbfe27339bb9a2a52a280"

data = data.scan(/../).map{|x| x.to_i(16).chr}.join

def encryption(k, x, data)
  crypto = ""
  (0...data.size).step(4) {|i|
    c = data[i, 4].unpack("V")[0] ^ k
    crypto << [c].pack("V")
    k = (c + x) % 0x1_0000_0000
  }
  crypto
end

def decryption(k, x, data)
  plain = ""
  (0...data.size).step(4) {|i|
    c = data[i, 4].unpack("V")[0]
    break if c.nil?
    p = c ^ k
    # pp [:decoding, k, x, c, p]
    k = (c + x) % 0x100000000
    plain << [p].pack("V")
  }
  plain
end


def test
  x = 12345456
  k = 563465365
  plain = "Cats are so totally awesome!"
  crypto = encryption(k, x, plain)
  plain2 = decryption(k, x, crypto)
  puts plain2
end

test

x0 = 0x14
x1 = 0xe9
x2 = 0xfd
(0..0xff).each{|x3|
  x = x3 * 0x100_0000 + x2 * 0x10000 + x1 * 0x100 + x0
  (0..0).each{|k|
    out = decryption(k, x, data)
    outc = out.unpack("C*")
    sample = (4...data.size).map{|j| next if j % 4 > 3; outc[j]}.compact
    next if sample.any?{|c| c > 128}
    p ["%x" % x, k, sample.map(&:chr).join]
  }
}
