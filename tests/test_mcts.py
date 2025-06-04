from alphazero_chess.board import Board
from alphazero_chess.mcts import MCTS


def test_mcts_selects_move():
    board = Board()
    mcts = MCTS(simulations=5)
    move = mcts.run(board)
    assert move is not None
    assert isinstance(move.start, tuple) and isinstance(move.end, tuple)
