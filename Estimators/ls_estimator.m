function Hls = ls_estimator(HpilotLs,pilotIdx,numActive)
%LS_ESTIMATOR Least-squares channel estimator with shape-preserving pilot interpolation.
pilotIdx = pilotIdx(:);
HpilotLs = HpilotLs(:);
allIdx = (1:numActive).';
if numel(pilotIdx) == 1
    Hls = repmat(HpilotLs,numActive,1);
else
    Hr = interp1(pilotIdx,real(HpilotLs),allIdx,'pchip','extrap');
    Hi = interp1(pilotIdx,imag(HpilotLs),allIdx,'pchip','extrap');
    Hls = Hr + 1j*Hi;
end
end
