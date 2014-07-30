#!/usr/bin/env ruby

class SuperhackThread
  attr_accessor :pc, :dir
  def initialize(machine)
    @machine = machine
    @pc      = pc
    @dir     = [1,0]
  end

  def alive?
    false
  end

  def step!
  end
end

class Superhack
  attr_accessor :code
  attr_accessor :output

  def initialize
    @output  = ""
    @threads = [SuperhackThread.new(self)]
  end

  def current_opcode
    x, y = @pc
    (@code[x] || [])[y] || ' '
  end

  def run!
    while @threads.any?(&:alive?)
      @threads.each do |thr|
        thr.step!
      end
    end
  end
end
