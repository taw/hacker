#!/usr/bin/env ruby

require "pp"

class Integer
  def roll(i,n)
    raise "#{self} out of range (0..#{2**n - 1})" if self < 0 or self >= 2**n
    ((self << i) | (self >> (n-i))) & ((2**n) - 1)
  end
end

data = "382d817119a18844865d880255a8221d90601ad164e8a8e1dd8a48f45846152255f839e09ab176154244faa95513d16e5e314078a97fdb8bb6da8d5615225695225674a4001a9177fb112277c45e17f85753c504d7187ed3cd43b107803827e09502559bf164292affe8aaa8e88ac898f9447119a188448692070056a2628864e6d7105edc5866b9b9b6ebcad6dc3982952a7674a62015025695225674a400d8715efb112277c45edb799f9728355c586f95b002e8aa815b83df3704571b99b6346426bd9862920721751857cb38f69bb3dee18ce1793bc857e27f74a400dd8a48d971bc15d07f521921b80948a86a8eb70457d1138279a796b8fbc43d9801e8ead669c8dcb10781788b5fe91097bad104d9ab952190a15ae706b50477b8dbe4d3cd437119c12842a42190e1a868aeb76446588d52b1078057e27cf7c65fa84aae5b8bbf6b88c19b9176a94a8eb7045778513712f1679b655d9c0255e88ac889b882b8f104711ba1dbabd7120520e188e195225655a802c184a0282affa86a8eb70457120542f7187658515f154244548a4212074278e7c6d3cd4595283e3d9a61d8ad56ba294878c5e69502551bf162487886280aff7b3309"

data = data.scan(/../).map{|x| x.to_i(16)}

def encode(txt, key)
  ciphertext = []
  txt.each_slice(3) do |a,b,c|
    eggs = (a << 16) + (b << 8) + c
    3.times do
      subkey = key[eggs&0x03] << 8
      eggs ^= subkey
      eggs = eggs.roll(7, 24)
    end
    ciphertext += [(eggs>>16), eggs>>8, eggs].pack("C*").unpack("C*")
  end
  ciphertext
end

def decode(txt, key)
  ciphertext = []
  txt.each_slice(3) do |a,b,c|
    eggs = (a << 16) + (b << 8) + c

    3.times do
      eggs = eggs.roll(24-7, 24)
      subkey = key[eggs&0x03] << 8
      eggs ^= subkey
    end

    ciphertext += [(eggs>>16), eggs>>8, eggs].pack("C*").unpack("C*")
  end
  ciphertext
end


key = [12, 44, 91, 117]
ciphertext = encode("Hello, kitty".unpack("C*"), key)
plaintext  = decode(ciphertext, key)

puts plaintext.pack("C*")
