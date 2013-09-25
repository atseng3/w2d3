require './piece.rb'

class Board
  attr_accessor :board_map

  INIT_POS = [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook]

  def initialize
    @board_map = create_board
  end

  def [](pos)   #this doesn't work yet - we need to figure out why
    @board_map[pos[0]][pos[1]]
  end

  def create_board
    empty_board = Array.new(8) { Array.new(8) }
    empty_board[6].each_index { |index| empty_board[6][index] = Pawn.new(self, :white) }
    empty_board[1].each_index { |index| empty_board[1][index] = Pawn.new(self, :green) }
    empty_board[0].each_index { |index| empty_board[0][index] = INIT_POS[index].new(self, :green) }
    empty_board[7].each_index { |index| empty_board[7][index] = INIT_POS[index].new(self, :white) }
    empty_board
  end

  def to_s
    board_str = ""
    @board_map.each_index do |x| # row number
      board_str += "#{8-x} "
      @board_map.each_index do |y| # column number
        if (x + y) % 2 == 0
          board_str += (@board_map[x][y].to_s.on_red + " ".on_red)
        else
          board_str += (@board_map[x][y].to_s + " ")
        end
      end
      board_str += "\n"
    end
    board_str += "  a b c d e f g h\n"
    board_str
  end

  def valid_move?(old_pos, new_pos, color)
    !blatantly_illegal?(@board_map, old_pos, new_pos, color) &&
     @board_map[old_pos[0]][old_pos[1]].valid_move?(old_pos, new_pos) #Piece
  end

  def blatantly_illegal?(board, old_pos, new_pos, color)
    !inside_the_board?(old_pos, new_pos) ||
    !my_piece_at_start?(board, old_pos, color) ||
    my_piece_at_end?(board, new_pos, color)
  end

  def inside_the_board?(old_pos, new_pos)
    positions = old_pos + new_pos
    positions.each { |position| return false if position.nil? || !position.between?(0,7)}
    true
  end

  def my_piece_at_start?(board, old_pos, color)
    board[old_pos[0]][old_pos[1]].color == color
  end

  def my_piece_at_end?(board, new_pos, color)
    board[new_pos[0]][new_pos[1]].color == color
  end

  def move(old_pos, new_pos)
    @board_map[old_pos[0]][old_pos[1]].move(old_pos, new_pos) #Piece
  end

  def check?(color, old_pos, new_pos)
    opposite_color = swap_color(color)
    duped_board = dup_the_board

    # try out the move on the duplicated board
    duped_board[old_pos[0]][old_pos[1]] = nil
    duped_board[new_pos[0]][new_pos[1]] = @board_map[old_pos[0]][old_pos[1]]

    king_pos = find_king_pos(duped_board, color)

    piece_attacking_king?(duped_board, king_pos, opposite_color)
  end

  def dup_the_board
    duped_board = Array.new(8) { Array.new(8) }
    @board_map.each_with_index { |row, index| duped_board[index] = row.dup }
    duped_board
  end

  def find_king_pos(duped_board, color)
    king_pos = nil
    duped_board.each_index do |x| # row number
      duped_board.each_index do |y| # column number
        if duped_board[x][y].is_a?(King) && duped_board[x][y].color == color
          king_pos = [x,y]
        end
      end
    end
    king_pos
  end

  def piece_attacking_king?(duped_board, king_pos, opposite_color)
    # loop through opposite_color's pieces.
    # for each piece, see if it is a legal move to go to king_pos
    # if there is even one piece like this, return true
    duped_board.each_index do |x| # row number
      duped_board.each_index do |y| # column number
        if duped_board[x][y].color == opposite_color
          piece = duped_board[x][y]
          return true if piece.piece_can_move_there?(duped_board,[x,y],king_pos)
          && !blatantly_illegal?(duped_board, [x,y], king_pos, opposite_color)
        end
      end
    end
    false
  end

  def checkmate?(color)
    all_positions = [0,1,2,3,4,5,6,7].product([0,1,2,3,4,5,6,7])
    opposite_color = swap_color(color)

    # loop through all pieces of color
    @board_map.each_index do |x| # row number
      @board_map.each_index do |y| # column number
        if @board_map[x][y].color == color
          piece = @board_map[x][y]

          possible_new_pos = all_positions.select do |pos| # only valid moves
            piece.piece_can_move_there?(@board_map, [x,y], pos) &&
            !blatantly_illegal?(@board_map, [x,y], pos, color)
          end

          possible_new_pos.each do |new_pos| # see if this move avoids check
            return false if !check?(color, [x,y], new_pos)
          end
        end
      end
    end
    true
  end

  def swap_color(color)
    opposite_color = (color == :white ? :green : :white)
  end
end
