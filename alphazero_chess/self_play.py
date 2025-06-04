from .board import Board
from .mcts import MCTS


def play_game(simulations: int = 50):
    board = Board()
    mcts = MCTS(simulations=simulations)
    moves = []
    for _ in range(200):  # limit moves to avoid infinite games
        move = mcts.run(board)
        moves.append(move)
        board.move_piece(move)
        if not board.generate_pseudo_legal_moves():
            break
    return moves


def main():
    moves = play_game()
    for mv in moves:
        print(f"{mv.start}->{mv.end}{'x' if mv.capture else ''}")


if __name__ == "__main__":
    main()
