import math
import random
from typing import Dict, List, Optional

from .board import Board, Move
from .network import RandomNetwork


class TreeNode:
    def __init__(self, board: Board, parent: Optional['TreeNode'] = None):
        self.board = board
        self.parent = parent
        self.children: Dict[Move, 'TreeNode'] = {}
        self.visit_count = 0
        self.value_sum = 0.0
        self.prior: Dict[Move, float] = {}

    def q_value(self) -> float:
        return self.value_sum / self.visit_count if self.visit_count else 0.0


class MCTS:
    def __init__(self, network: Optional[RandomNetwork] = None, c_puct: float = 1.0, simulations: int = 50):
        self.network = network or RandomNetwork()
        self.c_puct = c_puct
        self.simulations = simulations

    def select(self, node: TreeNode) -> TreeNode:
        while node.children:
            best_score = -float('inf')
            best_move = None
            for move, child in node.children.items():
                prior = node.prior.get(move, 1.0 / len(node.children))
                u = self.c_puct * prior * math.sqrt(node.visit_count) / (1 + child.visit_count)
                score = child.q_value() + u
                if score > best_score:
                    best_score = score
                    best_move = move
            node = node.children[best_move]
        return node

    def expand(self, node: TreeNode):
        moves = node.board.generate_pseudo_legal_moves()
        policy = self.network.predict(node.board, moves)
        node.prior = {mv: p for mv, p in zip(moves, policy)}
        for move in moves:
            next_board = node.board.copy()
            next_board.move_piece(move)
            node.children[move] = TreeNode(next_board, parent=node)

    def simulate(self, node: TreeNode) -> float:
        return self.network.value(node.board)

    def backpropagate(self, path: List[TreeNode], value: float):
        for node in reversed(path):
            node.visit_count += 1
            node.value_sum += value
            value = -value

    def run(self, board: Board) -> Move:
        root = TreeNode(board.copy())
        self.expand(root)
        for _ in range(self.simulations):
            node = root
            path = [node]
            while node.children:
                node = self.select(node)
                path.append(node)
            if node.visit_count == 0:
                value = self.simulate(node)
            else:
                self.expand(node)
                value = self.simulate(node)
            self.backpropagate(path, value)
        # pick the most visited move from the root
        best_move = max(root.children.items(), key=lambda item: item[1].visit_count)[0]
        return best_move
