# AlphaZero Chess (Simplified)

This repository contains a minimal educational implementation of an
AlphaZero-style chess engine in pure Python. The goal is to showcase
the general structure of Monte Carlo Tree Search (MCTS) combined with a
neural network-like policy/value predictor. Because this environment
lacks external dependencies, the "network" is a random placeholder and
the chess rules are simplified.

## Running a Self-Play Game

```bash
python -m alphazero_chess.self_play
```

## Running Tests

```bash
pytest
```
