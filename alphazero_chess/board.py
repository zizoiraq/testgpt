from dataclasses import dataclass
from typing import List, Tuple

Piece = str
Square = Tuple[int, int]

@dataclass(frozen=True)
class Move:
    start: Square
    end: Square
    capture: bool = False

class Board:
    """Simple chess board representation.

    This is a minimal board implementation that supports basic piece movement.
    It does not handle all chess rules like castling, en passant or check.
    It is meant as a lightweight environment for AlphaZero-style algorithms.
    """

    def __init__(self):
        # Standard chess starting position
        self.board: List[List[Piece]] = [
            list("rnbqkbnr"),
            ["p"]*8,
            [" "]*8,
            [" "]*8,
            [" "]*8,
            [" "]*8,
            ["P"]*8,
            list("RNBQKBNR"),
        ]
        self.turn: str = "white"  # 'white' or 'black'

    def in_bounds(self, sq: Square) -> bool:
        r, c = sq
        return 0 <= r < 8 and 0 <= c < 8

    def piece_at(self, sq: Square) -> Piece:
        r, c = sq
        return self.board[r][c]

    def move_piece(self, move: Move):
        sr, sc = move.start
        er, ec = move.end
        piece = self.board[sr][sc]
        self.board[sr][sc] = " "
        self.board[er][ec] = piece
        self.turn = "black" if self.turn == "white" else "white"

    def generate_pseudo_legal_moves(self) -> List[Move]:
        moves: List[Move] = []
        for r in range(8):
            for c in range(8):
                p = self.board[r][c]
                if p == " ":
                    continue
                if self.turn == "white" and p.isupper():
                    moves.extend(self._piece_moves((r, c), p))
                elif self.turn == "black" and p.islower():
                    moves.extend(self._piece_moves((r, c), p))
        return moves

    def _piece_moves(self, sq: Square, piece: Piece) -> List[Move]:
        r, c = sq
        moves: List[Move] = []
        directions = []
        if piece.lower() == "p":
            direction = -1 if piece.isupper() else 1
            start_row = 6 if piece.isupper() else 1
            next_sq = (r + direction, c)
            if self.in_bounds(next_sq) and self.piece_at(next_sq) == " ":
                moves.append(Move((r, c), next_sq))
                if r == start_row:
                    jump_sq = (r + 2 * direction, c)
                    if self.piece_at(jump_sq) == " ":
                        moves.append(Move((r, c), jump_sq))
            for dc in [-1, 1]:
                cap_sq = (r + direction, c + dc)
                if self.in_bounds(cap_sq):
                    target = self.piece_at(cap_sq)
                    if target != " " and target.isupper() != piece.isupper():
                        moves.append(Move((r, c), cap_sq, capture=True))
            return moves
        elif piece.lower() == "n":
            directions = [
                (-2, -1), (-2, 1), (-1, -2), (-1, 2),
                (1, -2), (1, 2), (2, -1), (2, 1)
            ]
        elif piece.lower() == "b":
            directions = [(-1, -1), (-1, 1), (1, -1), (1, 1)]
        elif piece.lower() == "r":
            directions = [(-1, 0), (1, 0), (0, -1), (0, 1)]
        elif piece.lower() == "q":
            directions = [(-1, -1), (-1, 1), (1, -1), (1, 1), (-1, 0), (1, 0), (0, -1), (0, 1)]
        elif piece.lower() == "k":
            directions = [
                (-1, -1), (-1, 0), (-1, 1),
                (0, -1),          (0, 1),
                (1, -1),  (1, 0), (1, 1)
            ]
            for dr, dc in directions:
                nr, nc = r + dr, c + dc
                if not self.in_bounds((nr, nc)):
                    continue
                target = self.piece_at((nr, nc))
                if target == " " or target.isupper() != piece.isupper():
                    moves.append(Move((r, c), (nr, nc), capture=target != " "))
            return moves

        for dr, dc in directions:
            nr, nc = r + dr, c + dc
            while self.in_bounds((nr, nc)):
                target = self.piece_at((nr, nc))
                if target == " ":
                    moves.append(Move((r, c), (nr, nc)))
                else:
                    if target.isupper() != piece.isupper():
                        moves.append(Move((r, c), (nr, nc), capture=True))
                    break
                if piece.lower() in ("n", "k"):
                    break
                nr += dr
                nc += dc
        return moves

    def copy(self) -> 'Board':
        new = Board()
        new.board = [row[:] for row in self.board]
        new.turn = self.turn
        return new
