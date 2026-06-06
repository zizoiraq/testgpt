# Deep Residual Learning-Based Channel Estimation for DCO-OFDM VLC Systems Under Shot Noise

This repository contains a complete MATLAB R2024a research framework for DCO-OFDM visible-light communication (VLC) channel estimation under combined AWGN and physically modeled shot noise.

## Compared estimators

1. Least Squares (LS) with pilot interpolation
2. Full linear MMSE using frequency-domain channel covariance matrices
3. CNN-based regression estimator
4. Proposed Deep Residual Network (DRN) / deep residual learning-based estimator

## Run

Open MATLAB R2024a in the repository root and execute:

```matlab
main
```

The script automatically generates data, trains neural estimators, evaluates QPSK and 16QAM DCO-OFDM links, exports result tables, and saves 300 dpi publication-quality figures in `Results/`.
