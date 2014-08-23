#!/usr/bin/env ruby

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

@functions = split_into_functions!
print_call_graph!
