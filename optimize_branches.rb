#!/usr/bin/env ruby

require "pp"

def optimize_useless_return!
  @branches.gsub!("return paramLong = ", "return ")
end

def constant_propagation!
  constant_funs = {}
  # Kill all constant functions
  @branches.gsub!(
  %r[long\s+([a-zA-Z0-9]+)\(long\s+paramLong\)
    \s*\{\s*
      return\s+(-?\d+L);
    \s*\}\s*
  ]x){
    constant_funs[$1] = $2
    ""
  }
  constant_funs.each do |k,v|
    @branches.gsub!(%r[\s#{k}\( [^\(\)]+ \)]x, " #{v}")
  end
end

def simple_funcall_propagation!
  simple_funs = {}
  @branches.gsub!(
  %r[long\s+([a-zA-Z0-9]+)\(long\s+paramLong\)
    \s*\{\s*
    return\s+([a-zA-Z0-9]+)\(paramLong\);
    \s*\}\s*
  ]x){
    simple_funs[$1] = $2
    ""
  }
  simple_funs.each do |k,v|
    @branches.gsub!(%r[\s#{k}(\( [^\(\)]+ \))]x) { " #{v}#{$1}" }
  end
end

@branches = open("Branches.java").read()
STDERR.puts @branches.size

optimize_useless_return!
5.times do
  constant_propagation!
  simple_funcall_propagation!
end

STDERR.puts @branches.size

puts @branches
