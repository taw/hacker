#!/usr/bin/env ruby

class HVM
  attr_accessor :code
  attr_accessor :output
  attr_accessor :mem
  def initialize
    @mem     = 16384.times.map{ 0 }
    @stack   = []
    @callstack = []
    @code    = ""
    @output  = ""
    @pc      = 0
    @stopped = false
  end

  def stopped?
    @stopped
  end

  def push(v)
    @stack.push(v)
  end

  def pop
    @stack.pop
  end

  def step!
    command = @code[@pc]
    # puts "Running `#{command}' #{@pc} - #{@stack.inspect} - #{@mem[0,4].map(&:inspect)}"
    @pc += 1
    case command
    when ' '
    when "p"
      @output << pop.to_s
    when "P"
      @output << (pop & 0x7F).chr
    when /\A[0-9]\z/
      push command.to_i
    when "+"
      a,b=pop,pop
      push(b+a)
    when "-"
      a,b=pop,pop
      push(b-a)
    when "*"
      a,b=pop,pop
      push(b*a)
    when "/"
      a,b=pop,pop
      push(b/a)
    when ":"
      a,b = pop,pop
      if b < a
        push -1
      elsif b == a
        push 0
      else
        push 1
      end
    when "g"
      @pc += pop
    when "?"
      a,b = pop,pop
      @pc += a if b == 0
    when "c"
      new_pc = pop
      @callstack.push(@pc)
      @pc = new_pc
    when "$"
      @pc = @callstack.pop
    when "<"
      push @mem[pop]
    when ">"
      a,b = pop,pop
      @mem[a] = b
    when "^"
      where = pop
      push @stack[-1-where]
    when "v"
      where = pop
      v = @stack[-1-where]
      @stack[-1-where] = nil
      @stack.compact!
      push v
    when "d"
      pop
    when "!", nil
      @stopped = true
    when "X"
      require 'pry'; binding.pry
    else
      raise "Unknown command `#{command}'"
    end
  end

  def run!
    until stopped?
      step!
    end
  end
end

if $0 == __FILE__
  hvm = HVM.new
  hvm.code = ARGV[0]
  hvm.run!
  puts hvm.output
end
