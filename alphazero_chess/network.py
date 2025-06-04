import random
from typing import List

from .board import Board, Move

class RandomNetwork:
    """A placeholder neural network that outputs random policy and value."""

    def predict(self, board: Board, moves: List[Move]) -> List[float]:
        # return a random probability distribution over moves
        n = len(moves)
        if n == 0:
            return []
        probs = [random.random() for _ in range(n)]
        total = sum(probs)
        return [p / total for p in probs]

    def value(self, board: Board) -> float:
        # return a random value between -1 and 1
        return random.uniform(-1.0, 1.0)
