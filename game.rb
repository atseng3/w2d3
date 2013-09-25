require 'colorize'
require './board.rb'

class Game
  def initialize
    @board = Board.new
    @turn = :white
  end

  def play
    until @board.checkmate?(@turn)
      play_one_turn
    end
    display_winner
  end

  def play_one_turn
    positions = get_user_move
    old_pos, new_pos = positions[0], positions[1]
    if @board.valid_move?(old_pos, new_pos, @turn)
      @board.move(old_pos, new_pos)
      @turn = @board.swap_color(@turn)
    else
      puts "\nIllegal move."
    end
  end

  def get_user_move
    puts "\n"
    puts @board
    puts "\nPlease enter your move. It is #{@turn.to_s}'s turn."
    positions = gets.chomp.split(' ')
    positions.map! { |pos| convert(pos) }
  end

  def convert(position)
    [8 - position[1].to_i, "abcdefgh".index(position[0])]
  end

  def display_winner
    puts @board
    winner = @board.swap_color(@turn)
    puts "\nCheckmate! #{winner.to_s.capitalize} wins!"
    exit
  end
end

class NilClass
  def to_s
    " "
  end

  def color
    :nil
  end
end

game = Game.new
game.play