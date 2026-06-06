function Hmmse = mmse_estimator(HpilotLs,pilotIdx,numActive,NFFT,L,noiseVariance)
%MMSE_ESTIMATOR Full linear MMSE estimator H = Rhp * inv(Rpp + sigma2 I) * H_LS.
pilotIdx = pilotIdx(:);
HpilotLs = HpilotLs(:);
activeZeroBased = (1:numActive).';
pilotZeroBased = activeZeroBased(pilotIdx);
pdp = exp(-(0:L-1).'/max(1,L/3));
pdp = pdp/sum(pdp);
Rhh = local_frequency_covariance(activeZeroBased,activeZeroBased,pdp,NFFT);
Rhp = Rhh(:,pilotIdx);
Rpp = Rhh(pilotIdx,pilotIdx);
regularizedPilotCovariance = Rpp + noiseVariance*eye(numel(pilotIdx));
Hmmse = Rhp * (regularizedPilotCovariance \ HpilotLs);
end

function R = local_frequency_covariance(kRows,kCols,pdp,NFFT)
R = zeros(numel(kRows),numel(kCols));
for tap = 0:numel(pdp)-1
    phaseRows = exp(-1j*2*pi*(kRows(:))*tap/NFFT);
    phaseCols = exp( 1j*2*pi*(kCols(:).')*tap/NFFT);
    R = R + pdp(tap+1)*(phaseRows*phaseCols);
end
end
