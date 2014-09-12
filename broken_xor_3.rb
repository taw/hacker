#!/usr/bin/env ruby

@data = '8d541ae26426f8b97426b7ae7240d78e401f8f904717d09b2fa4a4622cfcbf7337fbba2cdbcb4e3cdb994812b66a27e9e02f21faf8712bd2907fc384564998857e3b1'

@decoding = {}

def valid?(i)
  # most < 32 are invalid too
  i <= 126 and i >= 32
end

def decode(b, x, i)
  @decoding[[b,x,i]] ||= begin
    puts "Test #{b} #{x} #{i}"
    remaining = @data[i..-1]
    out = []
    if remaining.size == 0
      out << ""
    else
      # There are two possibilities
      d0 = remaining[0, 1].to_i(16)
      p0 = b^d0
      if valid?(p0)
        c0 = p0.chr
        out += decode((b+x) & 0xFF, x, i+1).map{|u| c0 + u}
        # out += decode((b+x) & 0xFF, x, i+1)
      end
      if d0 > 0 and remaining.size >= 2
        d1 = remaining[0, 2].to_i(16)
        p1 = b^d1
        if valid?(p1)
          c1 = p1.chr
          out += decode((b+x) & 0xFF, x, i+2).map{|u| c1 + u}
          # out += decode((b+x) & 0xFF, x, i+2)
        end
      end
    end
    puts "Returning #{b} #{x} #{i} #{out.size}"
    out.uniq
  end
end

(0..255).each do |b|
  (1..255).each do |x| # Let's just ignore x=0, that's too silly and slow
    puts "Trying #{b} #{x}"
    decode(b, x, 0).each do |xxx|
      puts "SUCCESS #{b} #{x}: #{xxx}"
    end
  end
end
