function nmse = calculate_nmse(Htrue,Hest)
%CALCULATE_NMSE Normalized mean squared channel-estimation error.
nmse = sum(abs(Htrue(:)-Hest(:)).^2)/(sum(abs(Htrue(:)).^2)+eps);
end
