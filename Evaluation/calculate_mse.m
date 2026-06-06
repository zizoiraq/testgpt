function mse = calculate_mse(Htrue,Hest)
%CALCULATE_MSE Mean squared channel-estimation error.
err = Htrue(:) - Hest(:);
mse = mean(abs(err).^2);
end
