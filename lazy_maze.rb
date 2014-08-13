#!/usr/bin/env ruby

require "moneta"
require "open-uri"

@monuments_cache = Moneta.new(:File, :dir => 'lazy_maze_cache')

def cached_get(url)
  @monuments_cache[url] ||= open(url).read
end

def maze_get(*steps)
  url = "http://www.hacker.org/challenge/misc/maze.php?steps=#{steps.join}"
  cached_get(url)
end

@directions = ["U", "D", "L", "R"]

def explore(start)
  here = maze_get(start)
  return if here =~ /boom|off the edge of the world/
  if start.size >= 150
    puts "CONTINUE? #{start}"
    return
  end
  if here =~ /keep moving/
    if start.size >= 100
      puts "KEEP MOVING: #{start}"
    end
    @directions.each{|a|
      explore(start+a)
    }
  else
    puts "WHAT IS: `#{here}' ?"
  end
end

explore("")
