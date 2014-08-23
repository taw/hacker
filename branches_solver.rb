#!/usr/bin/env ruby

class Integer
  def u64
    [self].pack("Q").unpack("Q")[0]
  end
  def i64
    [self].pack("Q").unpack("q")[0]
  end
end

def split_into_functions!
  current = nil
  functions = {}
  open("Branches.java").each_line do |line|
    line.chomp!
    next if line !~ /\S/
    prefix = line[/\A\s*/]
    break if line =~ /public static void main/
    if prefix.size == 0
      next
    elsif prefix.size == 2
      case line
      when "{"
        # ignore
      when "}"
        current = nil
      when /\A  long (.*?)\(long paramLong\)\z/
        current = $1
        raise if functions[current]
        functions[current] = []
      end
    else
      functions[current] << line
    end
  end
  functions
end

# This is meant to be piped into tsort
# There's one loop:
#   eL
#   sy
#   lC
def print_call_graph!
  @functions.each do |name, body|
    targets = body.map{|line| line.scan(/(\S+?)\(/)}.flatten
    targets.each do |t|
      puts [name, t].join("\t")
    end
  end
end

def body_into_one_expr(*body)
  if body.size == 3
    raise unless body[0] == "    if (paramLong == 0L)"
    e_zero = body_into_one_expr(body[1])
    e_nonzero = body_into_one_expr(body[2])
    "(paramLong == 0) ? (#{e_zero}) : (#{e_nonzero})"
  elsif body.size == 1
    expr = body[0].dup
    raise unless expr.sub!(/;\z/, "")
    raise unless expr.sub!(/\A\s*return\s+/, "")
    expr.gsub!(/(\S+)\(/) { "_#{$&}" } # some functions have names like "or"
    expr
  else
    raise "Not sure what to do with this"
  end
end

def translate_to_ruby!
  code = "class Branches
    def initialize
      @cache = {}
    end
  "
  @functions.each do |name, body|
    body_expr = body_into_one_expr(*body)
    body_expr.gsub!(/\b(\d+)L\b/) { $1 }
    code << "
    def _#{name}(paramLong)
      @cache[['#{name}', paramLong]] ||= (#{body_expr}).i64
    end
  "
  end
  code << "end\n"
  puts code
  eval(code)
  branches = Branches.new
  puts branches._vq(390)
end

@functions = split_into_functions!
# print_call_graph!
translate_to_ruby!
