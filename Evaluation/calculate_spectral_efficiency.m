function se = calculate_spectral_efficiency(snrDb,mse)
%CALCULATE_SPECTRAL_EFFICIENCY SE = log2(1 + SNR/(1 + SNR*MSE)).
snrLinear = 10.^(snrDb/10);
se = log2(1 + snrLinear./(1 + snrLinear.*mse));
end
