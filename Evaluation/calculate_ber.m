function ber = calculate_ber(bits,bitsHat)
%CALCULATE_BER Bit error rate.
N = min(numel(bits),numel(bitsHat));
if N == 0, ber = NaN; return; end
ber = mean(logical(bits(1:N)) ~= logical(bitsHat(1:N)));
end
