#!/usr/bin/env ruby

require_relative "superhack"
require "minitest/autorun"

class TestSuperhack < Minitest::Test
  def cleanup_code(code)
    code = code.sub(/\A\n/, "").sub(/\n\s+\z/, "").split("\n")
    init_spaces = code[0][/\A\s*/]
    code.map do |line|
      if line[0, init_spaces.size] == init_spaces
        line[init_spaces.size..-1].split("")
      else
        require 'pry'; binding.pry
      end
    end
  end

  def assert_superhack(code: nil, output: nil)
    sh = Superhack.new
    sh.code = cleanup_code(code)
    sh.run!
    assert_equal output, sh.output
  end

  def test_1
    assert_superhack(
      code:
      '
        9s/x?\!
          p  1
          x  |
          \-=/
      ',
      output: "876543210"
    )
  end

  def test_2
    assert_superhack(
      code:
      '
        2@\!
          @
          @
          @
          |
          0
          1
          g
          P
          $
      ',
      output: "@@@@@"
    )
  end

  def test_3
    assert_superhack(
      code:
      '
      9&\0000@\!
        s  /\ @
       /\  || @
       p7  || @
       \/  || |
      $====/\=/
      ',
      output: "7777777777777777"
    )
  end
end
