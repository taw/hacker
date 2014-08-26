module PNM
  def self.load(path)
    open(path, "rb") do |fh|
      raise unless fh.readline == "P6\n"
      raise unless fh.readline =~ /\A(\d+) (\d+)\n\z/
      x, y = $1.to_i, $2.to_i
      raise unless fh.readline == "255\n"
      data = fh.read
      unless data.size == x*y*3
        require 'pry'; binding.pry
      end
      [x, y, data]
    end
  end

  def self.save(path, x, y, data)
    unless data.size == x*y*3
      require 'pry'; binding.pry
    end
    open(path, "wb") do |fh|
      fh.print "P6\n"
      fh.print "#{x} #{y}\n"
      fh.print "255\n"
      fh.print data
    end
  end
end
