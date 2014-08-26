module PNM
  def self.load(path)
    open(path) do |fh|
      raise unless fh.readline == "P6\n"
      raise unless fh.readline =~ /\A(\d+) (\d+)\n\z/
      x, y = $1.to_i, $2.to_i
      raise unless fh.readline == "255\n"
      data = fh.read
      raise unless data.size == x*y*3
      [x, y, data]
    end
  end

  def self.save(path, x, y, data)
    open(path, 'w') do |fh|
      fh.print "P6\n"
      fh.print "#{x} #{y}\n"
      fh.print "255\n"
      fh.print data
    end
  end
end
