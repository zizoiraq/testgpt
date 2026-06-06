function [h,Hactive,Hfull] = generate_vlc_channel(params,L)
%GENERATE_VLC_CHANNEL Realistic VLC impulse response with Lambertian LOS and exponential PDP.
if nargin < 2, L = params.defaultChannelTaps; end
pdp = exp(-(0:L-1).'/max(1,L/3));
pdp = pdp/sum(pdp);
smallScale = (randn(L,1)+1j*randn(L,1))/sqrt(2);
h = sqrt(pdp).*smallScale;
h(1) = h(1) + 1;                 % deterministic dominant LOS tap
h = h/norm(h) * params.vlc.Hdc;   % scale to physical DC gain
Hfull = fft([h; zeros(params.NFFT-L,1)],params.NFFT);
Hactive = Hfull(params.activeBins);
end
