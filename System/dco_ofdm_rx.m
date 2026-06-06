function rx = dco_ofdm_rx(y,params,modulation,HestActive,tx)
%DCO_OFDM_RX Full DCO-OFDM receiver: CP removal, FFT, equalization, and demodulation.
y = y(:);
yNoCp = y(params.cpLen+1:params.cpLen+params.NFFT);
Y = fft(yNoCp,params.NFFT);
Yactive = Y(params.activeBins);
if nargin >= 4 && ~isempty(HestActive)
    eqActive = Yactive(:)./(HestActive(:)+eps);
else
    eqActive = Yactive(:);
end
rx = struct('freqGrid',Y,'activeGrid',Yactive,'equalizedActive',eqActive);
if nargin >= 5 && isfield(tx,'bits')
    mask = true(params.numActive,1);
    mask(tx.pilotIdx) = false;
    dataEq = eqActive(mask);
    bitsHat = local_qam_demod(dataEq,local_mod_order(modulation));
    rx.dataSymbols = dataEq;
    rx.bits = bitsHat(1:min(numel(bitsHat),numel(tx.bits)));
end
end

function M = local_mod_order(modulation)
if strcmpi(string(modulation),'QPSK'), M = 4; elseif strcmpi(string(modulation),'16QAM'), M = 16; else, error('Unsupported modulation.'); end
end

function bits = local_qam_demod(sym,M)
sym = sym(:);
if M == 4
    bits = zeros(2*numel(sym),1);
    bits(1:2:end) = real(sym) >= 0;
    bits(2:2:end) = imag(sym) >= 0;
else
    scaled = sym*sqrt(10);
    bits = zeros(4*numel(sym),1);
    [b1,b2] = local_demod_4pam(real(scaled));
    [b3,b4] = local_demod_4pam(imag(scaled));
    bits(1:4:end)=b1; bits(2:4:end)=b2; bits(3:4:end)=b3; bits(4:4:end)=b4;
end
bits = logical(bits);
end

function [bA,bB] = local_demod_4pam(v)
levels = [-3 -1 1 3];
labels = [0 0; 0 1; 1 1; 1 0];
[~,idx] = min(abs(v(:)-levels),[],2);
bA = labels(idx,1); bB = labels(idx,2);
end
