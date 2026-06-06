function [Ypilot,Xpilot,pilotBins] = extract_pilots(Yfreq,Xfreq,pilotIdx,params)
%EXTRACT_PILOTS Extract received and transmitted pilot tones.
pilotBins = params.activeBins(pilotIdx);
Ypilot = Yfreq(pilotBins);
Xpilot = Xfreq(pilotBins);
end
