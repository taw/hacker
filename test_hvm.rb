require_relative "hvm"
require "minitest/autorun"

class TestHVM < Minitest::Test
  def assert_hvm(input: nil, output: nil)
    hvm = HVM.new
    hvm.code = input
    hvm.run!
    assert_equal output, hvm.output
  end

  def test_1
    assert_hvm input: "78*p", output: "56"
  end

  def test_2
    assert_hvm input: "123451^2v5:4?9p2g8pppppp", output: "945321"
  end

  def test_strlen
    hvm = HVM.new

    # push 0
    # loop:
    #   dup
    #   push mem[pop]
    #   if pop == 0
    #     jump +9
    #   else
    #     plus 1 address
    # 9:

    hvm.code = "00^<4?1+1cp"
    hvm.mem[0,5] = ['h', 'e', 'l', 'l', 'o']
    hvm.run!
    assert_equal "5", hvm.output
  end

  def test_king_rat
    hvm = HVM.new

    # if mem[0] > mem[1]: mem[1] = mem[0]
    # print mem[19]

    hvm.code = "0<10<1<:1:1+1?>1<21<2<:1:1+1?>2<32<3<:1:1+1?>3<43<4<:1:1+1?>4<54<5<:1:1+1?>5<65<6<:1:1+1?>6<76<7<:1:1+1?>7<87<8<:1:1+1?>8<98<9<:1:1+1?>9<91+9<91+<:1:1+1?>91+<92+91+<92+<:1:1+1?>92+<93+92+<93+<:1:1+1?>93+<94+93+<94+<:1:1+1?>94+<95+94+<95+<:1:1+1?>95+<96+95+<96+<:1:1+1?>96+<97+96+<97+<:1:1+1?>97+<98+97+<98+<:1:1+1?>98+<29*98+<29*<:1:1+1?>29*<29*1+29*<29*1+<:1:1+1?>29*1+<p"
    hvm.mem[0,8] = [10, -7, 152, 4, 99, 8, 1, 55]
    hvm.run!
    assert_equal "152", hvm.output
  end

  # a % b == a - (a/b*b)
  def test_mod
    hvm = HVM.new
    hvm.mem[0] = 174
    hvm.mem[1] = 42
    hvm.code = "0<0<1</1<*-p"
    hvm.run!
    assert_equal "6", hvm.output
  end
end


