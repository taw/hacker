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

  def test_xor_one_bit
    [
      [0, 0],
      [0, 1],
      [1, 0],
      [1, 1],
    ].each do |a,b|
      puts ""
      hvm = HVM.new
      hvm.push a
      hvm.push b
      hvm.code = "01^3^2**-++p"
      hvm.run!
      assert_equal "#{a^b}", hvm.output
    end
  end

  def test_xor_all
    [
      [0, 0],
      [0, 1],
      [1, 2],
      [42, 9],
      [117, 97],
      [174, 42],
      [255, 256],
      [88, 972],
    ].each do |a,b|
      hvm = HVM.new
      hvm.mem[0] = a
      hvm.mem[1] = b
      hvm.code = "01" + "0<0^2/0^0>2*-1<0^2/0^1>2*-01^3^2**-++1^*2v+1v0^+"  * 31 + "dp"
      hvm.run!
      assert_equal "#{a^b}", hvm.output
    end
  end

  def test_find_dup
    hvm = HVM.new
    hvm.mem[0,12] = [1,2,3,4,11,6,7,8,9,2,10,5]
    hvm.code = "0<0^1<-2?2gp!0<0^2<-2?2gp!0<0^3<-2?2gp!0<0^4<-2?2gp!0<0^5<-2?2gp!0<0^6<-2?2gp!0<0^7<-2?2gp!0<0^8<-2?2gp!0<0^9<-2?2gp!0<0^91+<-2?2gp!0<0^92+<-2?2gp!1<0^2<-2?2gp!1<0^3<-2?2gp!1<0^4<-2?2gp!1<0^5<-2?2gp!1<0^6<-2?2gp!1<0^7<-2?2gp!1<0^8<-2?2gp!1<0^9<-2?2gp!1<0^91+<-2?2gp!1<0^92+<-2?2gp!2<0^3<-2?2gp!2<0^4<-2?2gp!2<0^5<-2?2gp!2<0^6<-2?2gp!2<0^7<-2?2gp!2<0^8<-2?2gp!2<0^9<-2?2gp!2<0^91+<-2?2gp!2<0^92+<-2?2gp!3<0^4<-2?2gp!3<0^5<-2?2gp!3<0^6<-2?2gp!3<0^7<-2?2gp!3<0^8<-2?2gp!3<0^9<-2?2gp!3<0^91+<-2?2gp!3<0^92+<-2?2gp!4<0^5<-2?2gp!4<0^6<-2?2gp!4<0^7<-2?2gp!4<0^8<-2?2gp!4<0^9<-2?2gp!4<0^91+<-2?2gp!4<0^92+<-2?2gp!5<0^6<-2?2gp!5<0^7<-2?2gp!5<0^8<-2?2gp!5<0^9<-2?2gp!5<0^91+<-2?2gp!5<0^92+<-2?2gp!6<0^7<-2?2gp!6<0^8<-2?2gp!6<0^9<-2?2gp!6<0^91+<-2?2gp!6<0^92+<-2?2gp!7<0^8<-2?2gp!7<0^9<-2?2gp!7<0^91+<-2?2gp!7<0^92+<-2?2gp!8<0^9<-2?2gp!8<0^91+<-2?2gp!8<0^92+<-2?2gp!9<0^91+<-2?2gp!9<0^92+<-2?2gp!91+<0^92+<-2?2gp!"
    hvm.run!
    assert_equal "2", hvm.output
  end

  def test_broken_key
    [
      [32,117],
      [32,32],
      [117,32],
    ].each do |a,b|
      hvm = HVM.new
      hvm.mem[0,2] = [a,b]
      hvm.code = "0<1</4?0<p!1<p"
      hvm.run!
      assert_equal [a,b].max.to_s, hvm.output
    end
  end

  def test_broken_keys
    (1..100).each do |a|
      (1..100).each do |b|
        assert_equal [a,b].max, (1/((a+b)/b))*b + (1/((a+b-1)/a))*a
        hvm = HVM.new
        hvm.mem[0,2] = [a,b]
        hvm.code = "10<1<+1<//1<*10<1<+1-0<//0<*+p"
        hvm.run!
        assert_equal [a,b].max.to_s, hvm.output
      end
    end
  end

  def test_brokener_keys
    (0..255).each do |a|
      (0..255).each do |b|
        p [a,b]
        hvm = HVM.new
        hvm.mem[0,2] = [a,b]
        hvm.code = "0<1<888**0<1<--4*cp                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         0<p!                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            1<p!"
        hvm.run!
        assert_equal [a,b].max.to_s, hvm.output
        # assert_equal (4*(256+b-a)).to_s, hvm.output
      end
    end
  end

  def test_brokenest_keys
    (0..32).each do |a|
      (0..32).each do |b|
        p [a,b]
        hvm = HVM.new
        hvm.mem[0,2] = [a,b]
        hvm.code = "00^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0^1+0<^1<+4*95+9*7+9*3++c                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      0<p!                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        1<p!"
        hvm.run!
        assert_equal [a,b].max.to_s, hvm.output
        # p [a, b, hvm.output, 256-a+b]
      end
    end
  end

  def test_deja_vu
    values = ([142] + (101..227).to_a).shuffle
    hvm = HVM.new
    hvm.mem[0,128] = values
    hvm.code = "95+9*1+00^<2^<:2?5g0^<p!1+0^2^:2?8cd1-7c"
    hvm.run!
    assert_equal "142", hvm.output
  end

  def test_king_mouse
    hvm = HVM.new
    hvm.mem[0,19] = [209, 205, 202, 207, 219, 217, 201, 214, 210, 212, 211, 215, 218, 203, 204, 200, 206, 213, 208, 216].map{|x| x-210}
    hvm.code = "45*1-0^<0<:1+5?0^<0>0^2?3g<p!3c"
    hvm.run!

    assert_equal "9", hvm.output
  end
end
