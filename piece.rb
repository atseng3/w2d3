class Piece
  attr_accessor :board, :color, :display_char

  def initialize(board, color, display_char)
    @board = board
    @color = color
    @display_char = display_char
  end

  def to_s
    @display_char.send(@color)
  end

  def move(old_pos, new_pos)
    if valid_move?(old_pos, new_pos)
      @board.board_map[old_pos[0]][old_pos[1]] = nil
      @board.board_map[new_pos[0]][new_pos[1]] = self
    end
    nil
  end

  def valid_move?(old_pos, new_pos)
    self.piece_can_move_there?(@board.board_map, old_pos, new_pos) &&
    !@board.check?(self.color, old_pos, new_pos)
  end
end

class SlidingPiece < Piece

  def piece_can_move_there?(board, old_pos, new_pos)
    delta = [new_pos[0]-old_pos[0],new_pos[1]-old_pos[1]]
    bigger = (delta.map { |el| el.abs }).max
    delta.map! { |el| el / bigger.to_f }
    return false if !self.class::MOVE_DIRS.include?(delta)
    !crash?(board, old_pos, new_pos, delta)
  end

  def crash?(board, old_pos, new_pos, delta)
    pos = [old_pos[0]+delta[0],old_pos[1]+delta[1]]
    until pos == new_pos
      return true if board[pos[0]][pos[1]].is_a?(Piece)
      pos = [pos[0]+delta[0],pos[1]+delta[1]]
    end
    false
  end
end

class SteppingPiece < Piece
  def piece_can_move_there?(board, old_pos, new_pos)
    self.class::DELTAS.include?([new_pos[0]-old_pos[0],new_pos[1]-old_pos[1]])
  end
end

class Pawn < Piece
  def initialize(board, color)
    super(board, color, [9817].pack('U*'))
  end

  def piece_can_move_there?(board, old_pos, new_pos)
    delta = [new_pos[0]-old_pos[0],new_pos[1]-old_pos[1]]

    deltas = [[2,0],[1,0],[1,-1],[1,1]] #default is for GREEN
    deltas.map! {|arr| [arr[0] * -1, arr[1]] } if self.color == :white

    return false if !deltas.include?(delta)
    not_blocked?(board, delta, deltas, old_pos, new_pos)
    end
  end

  def not_blocked?(board, delta, deltas, old_pos, new_pos)
    case delta
    when deltas[0]
      one_ahead = [old_pos[0]+deltas[1][0],old_pos[1]]
      return board[one_ahead[0]][one_ahead[1]].nil? &&
             board[new_pos[0]][new_pos[1]].nil?
    when deltas[1]
      return board[new_pos[0]][new_pos[1]].nil?
    else
      return board[new_pos[0]][new_pos[1]].color != self.color &&
             board[new_pos[0]][new_pos[1]].color != :nil
  end
end

class Queen < SlidingPiece

  MOVE_DIRS = [[1,1],[1,-1],[-1,1],[-1,-1],[0,-1],[1,0],[0,1],[-1,0]]

  def initialize(board, color)
    super(board, color, [9813].pack('U*'))
  end
end

class Rook < SlidingPiece

  MOVE_DIRS = [[0,-1],[1,0],[0,1],[-1,0]]

  def initialize(board, color)
    super(board, color, [9814].pack('U*'))
  end
end


class Bishop < SlidingPiece

  MOVE_DIRS = [[1,1],[1,-1],[-1,1],[-1,-1]]

  def initialize(board, color)
    super(board, color, [9815].pack('U*'))
  end
end

class King < SteppingPiece

  DELTAS = [[0,1],[1,0],[1,-1],[-1,1],[0,-1],[-1,0],[-1,-1],[1,1]]

  def initialize(board, color)
    super(board, color, [9812].pack('U*'))
  end
end

class Knight < SteppingPiece

  DELTAS = [[2,1],[1,2],[2,-1],[-1,2],[1,-2],[-2,1],[-2,-1],[-1,-2]]

  def initialize(board, color)
    super(board, color, [9816].pack('U*'))
  end
end