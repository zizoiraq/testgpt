function [y,noiseVariance] = add_shot_noise(x,snrDb,params,Hdc)
%ADD_SHOT_NOISE Add AWGN and physical shot noise to a VLC waveform.
if nargin < 4, Hdc = params.vlc.Hdc; end
signalPower = mean(abs(x).^2);
awgnVariance = signalPower/10^(snrDb/10);
shotVariance = 2*params.vlc.q*(params.vlc.R*max(Hdc,0) + params.vlc.Ibg)*params.vlc.B;
noiseVariance = awgnVariance + shotVariance;
noise = sqrt(noiseVariance/2)*(randn(size(x))+1j*randn(size(x)));
y = x + noise;
end
