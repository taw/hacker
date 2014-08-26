#!/usr/bin/env ruby

require "pathname"
require "pp"
require "set"
require_relative "pnm"

module Enumerable
  def all_min_by
    res = []
    mindist = nil

    each do |elem|
      dist = yield(elem)
      if mindist.nil? or dist < mindist
        res = [elem]
        mindist = dist
      elsif dist == mindist
        res << elem
      end
    end

    [mindist, res]
  end
end

def pixel_dist((a,b,c), (d,e,f))
  Math.sqrt((a-b)**2 + (b-e)**2 + (c-f)**2)
end

def pixel_map_nearest(px)
  bg  = [0,0,0]
  px1 = [255, 255, 255]
  px0 = [35, 182, 153]

  return px if px == bg
  return px if px == px0
  return px if px == px1

  [bg, px0, px1].min_by{|x| pixel_dist(px, x) }
end

def pixel_map_force(px)
  bg  = [0,0,0]
  px1 = [255, 255, 255]
  px0 = [35, 182, 153]

  return px if px == bg
  return px if px == px0
  return px if px == px1

  # If in doubt, break it
  return bg
end

def pixel_map_threshold(px, thr=20)
  bg  = [0, 0, 0]
  px1 = [255, 255, 255]
  px0 = [35, 182, 153]

  return px if px == bg
  return px if px == px0
  return px if px == px1

  d0 = pixel_dist(px, px0)
  d1 = pixel_dist(px, px1)

  return px0 if d0 < d1 and d0 < thr
  return px1 if d1 < d0 and d1 < thr
  bg
end

def read_spiral_pixels
  x, y, data = PNM.load("spiral.pnm")
  data = data.unpack("C*").each_slice(1024*3).map do |row|
    row.each_slice(3).map do |px|
      pixel_map_threshold(px)
    end
  end
  [x, y, data]
end

def cleanup!
  x, y, pixels = read_spiral_pixels
  PNM.save("cleaned.pnm", x, y, pixels.flatten.pack("C*"))
end

def group_into_sets
  live_pixels = Set[]
  x, y, data = PNM.load("cleaned.pnm")
  data.unpack("C*").each_slice(1024*3).each_with_index do |row, y|
    row.each_slice(3).each_with_index do |px, x|
      next if px == [0, 0, 0]
      if px == [255, 255, 255]
        live_pixels << [x, y, 1]
      elsif px == [35, 182, 153]
        live_pixels << [x, y, 0]
      else
        # Cleanup didn't work ?
        require 'pry'; binding.pry
      end
    end
  end
  sets = []
  until live_pixels.empty?
    set  = Set[]
    candidates = [live_pixels.first]
    until candidates.empty?
      c = candidates.shift
      if live_pixels.include?(c)
        set << c
        live_pixels.delete(c)
        [-1,0,1].each do |dx|
          [-1,0,1].each do |dy|
            candidates << [c[0]+dx, c[1]+dy, c[2]]
          end
        end
      end
    end
    sets << set
  end

  # With very small or very large sets there could be some weirdness happening :-/
  sets.select{|set| set.size >= 3}
end

def save_sets_pic(sets)
  out = "\x00" * (1024*1024*3)
  sets.each do |set|
    color = [rand(256), rand(256), rand(256)].pack("CCC")
    set.each do |x,y,c|
      out[3*x + 3*1024*y, 3] = color
    end
  end
  PNM.save("sets.pnm", 1024, 1024, out)
end

def set_distance(a,b)
  return 1000 if a[:xmin] >= b[:xmax] + 10
  return 1000 if b[:xmin] >= a[:xmax] + 10
  return 1000 if a[:ymin] >= b[:ymax] + 10
  return 1000 if b[:ymin] >= a[:ymax] + 10
  a[:elems].map{|x1,y1,_|
    b[:elems].map{|x2,y2,_|  (x1-x2)**2 + (y1-y2)**2 }.min
  }.min
end

def merge_nearby_neighbours(a, b)
  puts "Merging #{a} and #{b} at distance #{set_distance(a, b)}"
  raise unless a[:bit] == b[:bit]
  {
    xmin: [a[:xmin], b[:xmin]].min,
    xmax: [a[:xmax], b[:xmax]].max,
    ymin: [a[:ymin], b[:ymin]].min,
    ymax: [a[:ymax], b[:ymax]].max,
    bit: a[:bit],
    elems: a[:elems] + b[:elems],
    size: a[:size] + b[:size],
  }
end

def follow_the_path(sets)
  sets = sets.map{|set|
    xs = set.map{|x,_,_| x}
    ys = set.map{|_,y,_| y}
    bit = set.first[-1]
    elems = set.map{|x,y,_| [x,y]}
    {xmin: xs.min, xmax: xs.max, ymin: ys.min, ymax: ys.max, bit: bit, elems: elems, size: set.size}
  }
  result = []
  sets = Set[*sets]
  current = sets.max_by{|set| set[:size]}
  sets.delete current

  while true
    result << current[:bit]

    break if sets.empty?

    mindist, neighbours = sets.all_min_by{|set|
      set_distance(set, current)
    }

    neighbours.each do |n|
      sets.delete n
    end

    if neighbours.size == 1
      current = neighbours[0]
    elsif neighbours.size == 2
      # This is potentially stupid :-/
      current = merge_nearby_neighbours(*neighbours)
    end

    # puts "Bit #{current[:bit]}, Distance #{mindist}, #{sets.size} left"
  end

  # Except for a few bad bits, it's almost working :-/
  File.open("spiral_result.png", "w"){|fh|
    fh.print result.reverse.join.scan(/.{8}/).map{|u|  u.to_i(2)}.pack("C*")
  }
end

cleanup! unless Pathname("cleaned.pnm").exist?
sets = group_into_sets
save_sets_pic(sets)
follow_the_path(sets)
