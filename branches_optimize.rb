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

def xorfun_propagation!
  xorfuns = {}
  @branches.gsub!(
  %r[long\s+([a-zA-Z0-9]+)\(long\s+paramLong\)
    \s*\{\s*
    return\s+(0x[A-F0-9]+)\s+\^\s+paramLong;
    \s*\}\s*
  ]x){
    xorfuns[$1] = $2
    ""
  }
  xorfuns.each do |k,v|
    @branches.gsub!(%r[\s#{k}(\( [^\(\)]+ \))]x) { " (#{v} ^ #{$1})" }
  end
end

def zeroq_optimize!
  zeroq = {}
  @branches.gsub!(
  %r[long\s+([a-zA-Z0-9]+)\(long\s+paramLong\)
    \s*\{\s*
    if\s+\(paramLong\s+==\s+0L\)\s+
      return\s+(\d+L);\s+
    return\s+(\d+L);\s+
    \s*\}\s*
  ]x){
    zeroq[$1] = "== 0 ? #{$2} : #{$3}"
    ""
  }
  zeroq.each do |k,v|
    @branches.gsub!(%r[\s#{k}(\( [^\(\)]+ \))]x) { " (#{$1} #{v})" }
  end
end

def minusone_optimize!
  minusone_fun = {}
  @branches.gsub!(
  %r[long\s+([a-zA-Z0-9]+)\(long\s+paramLong\)
    \s*\{\s*
    return\s+([a-zA-Z0-9]+)\(paramLong\s+-\s+1L\);
    \s*\}\s*
  ]x){
    minusone_fun[$1] = $2
    ""
  }
  minusone_fun.each do |k,v|
    @branches.gsub!(%r[\s#{k}(\( [^\(\)]+ \))]x) { " #{v}(#{$1} - 1L)" }
  end
end

@branches = open("Branches.java").read()
STDERR.puts @branches.size

optimize_useless_return!
5.times do
  constant_propagation!
end
5.times do
  zeroq_optimize!
  minusone_optimize!
  constant_propagation!
  simple_funcall_propagation!
  xorfun_propagation!
  @branches.gsub!(" (paramLong)", " paramLong")
  @branches.gsub!("(paramLong - 1L) - 1L", "paramLong - 2L")
end

STDERR.puts @branches.size

puts @branches
