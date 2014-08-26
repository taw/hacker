#!/usr/bin/env ruby

require "pathname"
require "pp"
require "set"
require_relative "pnm"

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
  bg  = [0,0,0]
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

unless Pathname("cleaned.pnm").exist?
  x, y, pixels = read_spiral_pixels
  PNM.save("cleaned.pnm", x, y, pixels)
end

sets = group_into_sets
save_sets_pic(sets)
