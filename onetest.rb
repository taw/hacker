#!/usr/bin/env ruby

def onetest(a)
  # mov    %eax,%edx
  d = a
  # sar    $0x1f,%edx
  d = d >> 0x1f
  # not    %edx
  d = 0xFFFF_FFFF ^ d
  # and    %eax,%edx
  d &= a
  # sub    $0x6fe5d5,%edx
  d -= 0x006f_e5d5
  # xor    $0x2eb22189,%edx
  d ^= 0x2eb22189
  # imul   $0x1534162,%edx,%edx
  ad = d * 0x0153_4162 # This is not correct :-/
  d = ad & 0xFFFF_FFFF
  # xor    $0x69f6bc7,%edx
  d ^= 0x069f_6bc7
  # mov    %edx,0x4(%esp)
  return [d].pack("V").unpack("l")[0]
end

def test!
  {
    1 => -1121857043,
    0 => -1319395901,
    100 => -275352181,
    -1 => -1319395901,
    1000000 => 1413085507,
    123456789 => 2090682933,
    -123456789 => -1319395901,
    42 => 37662207,
  }.each do |n,v|
    unless onetest(n) == v
      warn "Selftest for #{n} failed, expected #{v} got #{onetest(n)}"
    end
  end
end

test!
