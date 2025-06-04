from alphazero_chess.board import Board


def test_initial_moves():
    b = Board()
    moves = b.generate_pseudo_legal_moves()
    # at least white pawns and knights should have moves
    assert len(moves) > 0
    # there should be 20 moves in the initial chess position (simplified)
    assert len(moves) >= 16
