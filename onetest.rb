#!/usr/bin/env ruby

require "pp"

class Integer
  def u32
    [self].pack("V").unpack("V")[0]
  end
  def i32
    [self].pack("V").unpack("l")[0]
  end
end

def onetest(a)
  return -1319395901 if a < 0
  # sub    $0x6fe5d5,%edx
  a -= 0x006f_e5d5
  # xor    $0x2eb22189,%edx
  a ^= 0x2eb22189
  # imul   $0x1534162,%edx,%edx
  a *= 0x0153_4162
  # xor    $0x69f6bc7,%edx
  a ^= 0x069f_6bc7
  # mov    %edx,0x4(%esp)
  return a.i32
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
    a = onetest(n)
    warn "Selftest for #{n} failed, expected #{v} got #{a} (1)" unless a == v
  end
end

# target = 0x0dbb_832b # 230392619
# answer = solve_onetest(target)

test!
