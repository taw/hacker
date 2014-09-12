#!/usr/bin/env ruby

require "set"

games = 0
draws = 0

def won?(cells)
  [
    [1,2,3],
    [4,5,6],
    [7,8,9],
    [1,4,7],
    [2,5,8],
    [3,6,9],
    [1,5,9],
    [3,5,7],
  ].any?{|line|
    line.all?{|c| cells.include?(c)}
  }
end

def game_result(game)
  xs = [0,2,4,6,8].map{|i| game[i]}.compact
  # p xs
  os = [1,3,5,7].map{|i| game[i]}.compact
  # p os

  if won?(xs)
    if won?(os)
      :both
    else
      :x
    end
  elsif won?(os)
    :o
  else
    :draw
  end
end

all_games_by_result = {
  :x => Set[],
  :o => Set[],
  :draw => Set[],
}

board = [1, 2, 3, 4, 5, 6, 7, 8, 9]
board.permutation { |perm|

  next unless perm[0] == 5

  loop do
    result = game_result(perm)
    break if result == :draw
    smaller_perm = perm[0..-2]
    # puts "Testing #{smaller_perm.inspect} #{game_result(smaller_perm)}"
    if game_result(smaller_perm) == :draw
      break
    else
      perm = smaller_perm
    end
  end

    # puts "Game: #{perm.inspect} - #{game_result(perm)}"
    all_games_by_result[game_result(perm)] << perm

}
all_games_by_result.each{|r,gs|
  p [r, gs.size]
}

ratio = all_games_by_result[:draw].size.to_f / all_games_by_result.values.map(&:size).inject(&:+)
puts ratio.round(8)
