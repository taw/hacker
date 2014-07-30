require 'term/ansicolor'
require "pp"
require "set"

include Term::ANSIColor

class Array
  def duplicates
    seen = {}
    rv = Set[]
    each do |x|
      if seen[x]
        rv << x
      end
      seen[x] = true
    end
    rv.sort
  end
end

class String
  def stats
    rv = Hash.new(0)
    split('').each do |c|
      rv[c] += 1
    end
    rv.sort_by{|k,v| -v}
  end
end

def dec(txt, from, to)
  txt.gsub(/./) do
    i = from.index($&)
    if i
      green(to[i])
    else
      red($&)
    end
  end
end

def validate!(from, to)
  from_dups = from.split("").duplicates
  to_dups   = to.split("").duplicates
  warn "to contains duplicates: #{from_dups}" unless to_dups.empty?
  warn "from contains duplicates: #{from_dups}" unless from_dups.empty?
end
