#!/usr/bin/env ruby

require "pathname"
require "pp"
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

unless Pathname("cleaned.pnm").exist?
  x, y, pixels = read_spiral_pixels
  PNM.save("cleaned.pnm", x, y, pixels)
end
