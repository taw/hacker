#!/usr/bin/env ruby

require 'pry'

class SuperhackThread
  def initialize(machine)
    @machine = machine
    @x     = 0
    @y     = 0
    @mx    = 0
    @my    = 0
    @dir   = :right
    @alive = true
    @stack = []
    @callstack = []
  end

  def dx
    case @dir
    when :right
      1
    when :left
      -1
    else
      0
    end
  end

  def dy
    case @dir
    when :up
      -1
    when :down
      1
    else
      0
    end
  end

  def alive?
    @alive
  end

  def current_opcode
    @machine.opcode(@x, @y)
  end

  def move!
    @x += dx
    @y += dy
    binding.pry if @x < 0 or @y < 0 or @x >= 1024 or @y >= 128
  end

  def push(val)
    @stack.push(val)
  end

  def pop
    @stack.pop
  end

  def directions
    [:right, :down, :left, :up]
  end

  def turn!(x)
    @dir = directions[(directions.index(@dir)+x) % 4]
  end

  def step!
    puts "Executing <#{@x},#{@y},#{@dir}>: `#{current_opcode}' `#{@stack.inspect}'' `#{@machine.output}' `#{@callstack.inspect}'"
    case current_opcode
    when "%"
      raise "NotImplemented"
    when /[0-9]/
      push current_opcode.to_i
    when "p"
      @machine.print pop.to_s
    when "P"
      a = pop
      a = a.ord if a.is_a?(String)
      @machine.print (a&0x7f).chr
    when "!"
      @alive = false
    when "+"
      a,b=pop,pop
      push b+a
    when "-"
      a,b=pop,pop
      push b-a
    when "*"
      a,b=pop,pop
      push b*a
    when "d"
      a,b=pop,pop
      push b/a
    when ","
      push @machine.read
    when "s"
      move!
    when "\\"
      @dir = {
         left: :up,
           up: :left,
        right: :down,
         down: :right,
      }[@dir]
    when "/"
      @dir = {
        right: :up,
           up: :right,
         left: :down,
         down: :left,
      }[@dir]
    when ":"
      raise "NotImplemented"
    when "?"
      move! if pop == 0
    when '@'
      @callstack.push [@x, @y, @dir]
    when '$'
      @x, @y, @dir = @callstack.pop
      move!
    when '<'
      push memory_read(pop, pop)
    when '>'
      memory_write(pop, pop, pop)
    when '['
      @mx -= pop
    when ']'
      @mx += pop
    when '{'
      @my -= 1
    when '}'
      @my += 1
    when 'x'
      a = pop
      push a
      push a
    when '^'
      raise "NotImplementedYet"
    when 'v'
      raise "NotImplementedYet"
    when 'g'
      x=pop
      y=pop
      push @machine.opcode(x, y)
    when 'w'
      x=pop
      y=pop
      @machine.write_opcode(x, y, pop)
    # All unknown characters are noops, but for now whitelist them
    when '|', '='
      # noop
    else
      raise "Unknown opcode `#{current_opcode}'"
    end
    move!
  end
end

class Superhack
  attr_accessor :code
  attr_accessor :output

  def print(str)
    @output << str
  end

  def opcode(x, y)
    @code.fetch(y, []).fetch(x, ' ')
  end

  def write_opcode(x, y, val)
    @code[x] ||= []
    @code[x][y] = val
  end


  def initialize
    @output  = ""
    @threads = [SuperhackThread.new(self)]
  end

  def run!
    while @threads.any?(&:alive?)
      @threads.each do |thr|
        thr.step!
      end
    end
  end
end
