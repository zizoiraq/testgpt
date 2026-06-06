function tx = dco_ofdm_tx(bits,params,modulation,pilotIdx,pilotSymbols)
%DCO_OFDM_TX Full DCO-OFDM transmitter with QAM, pilots, Hermitian symmetry, IFFT, bias, clipping.
M = local_mod_order(modulation);
bps = log2(M);
numData = params.numActive - numel(pilotIdx);
neededBits = numData*bps;
if numel(bits) < neededBits
    error('dco_ofdm_tx:BitLength','At least %d bits are required.',neededBits);
end
bits = bits(1:neededBits);
dataSymbols = local_qam_mod(bits,M);
if nargin < 5 || isempty(pilotSymbols), pilotSymbols = ones(numel(pilotIdx),1); end
Xpos = insert_pilots(dataSymbols,pilotSymbols,pilotIdx,params.numActive);
X = zeros(params.NFFT,1);
X(params.activeBins) = Xpos;
X(params.NFFT - params.activeBins + 2) = conj(Xpos);
x = real(ifft(X,params.NFFT));
xcp = [x(end-params.cpLen+1:end); x];
biased = xcp + params.dcBias*std(xcp);
clipped = min(max(biased,params.clipMin),params.clipMax);
tx = struct('waveform',clipped,'freqGrid',X,'positiveGrid',Xpos,'dataSymbols',dataSymbols, ...
    'pilotSymbols',pilotSymbols(:),'pilotIdx',pilotIdx(:),'bits',bits(:),'modulation',string(modulation));
end

function M = local_mod_order(modulation)
if strcmpi(string(modulation),'QPSK'), M = 4; elseif strcmpi(string(modulation),'16QAM'), M = 16; else, error('Unsupported modulation.'); end
end

function sym = local_qam_mod(bits,M)
bits = bits(:); bps = log2(M); groups = reshape(bits,bps,[]).';
if M == 4
    levels = [-1 1];
    I = levels(groups(:,1)+1); Q = levels(groups(:,2)+1);
    sym = (I(:)+1j*Q(:))/sqrt(2);
else
    map = [-3 -1 3 1]; % Gray: 00 -3, 01 -1, 10 3, 11 1 with binary index + 1
    idxI = groups(:,1)*2 + groups(:,2) + 1;
    idxQ = groups(:,3)*2 + groups(:,4) + 1;
    sym = (map(idxI).'+1j*map(idxQ).')/sqrt(10);
end
end
