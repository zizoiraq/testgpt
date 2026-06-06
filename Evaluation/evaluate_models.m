function result = evaluate_models(params,modulation,pilotIdx,L,cnn,drn,varargin)
%EVALUATE_MODELS Evaluate LS, full MMSE, CNN, and proposed DRN estimators.
ip = inputParser;
addParameter(ip,'classicalOnly',false,@islogical);
parse(ip,varargin{:});
classicalOnly = ip.Results.classicalOnly;
methods = {'LS','MMSE'};
if ~classicalOnly && ~isempty(cnn), methods{end+1} = 'CNN'; end
if ~classicalOnly && ~isempty(drn), methods{end+1} = 'DRN'; end
numMethods = numel(methods);
numSnr = numel(params.snrDbRange);
mse = zeros(numSnr,numMethods);
nmse = zeros(numSnr,numMethods);
ber = zeros(numSnr,numMethods);
se = zeros(numSnr,numMethods);
example = struct();
for is = 1:numSnr
    snrDb = params.snrDbRange(is);
    mseAcc = zeros(params.numFramesEval,numMethods);
    nmseAcc = zeros(params.numFramesEval,numMethods);
    berAcc = zeros(params.numFramesEval,numMethods);
    for frame = 1:params.numFramesEval
        [h,Htrue] = generate_vlc_channel(params,L);
        numData = params.numActive - numel(pilotIdx);
        bps = local_bits_per_symbol(modulation);
        bits = randi([0 1],numData*bps,1);
        pilotSymbols = ones(numel(pilotIdx),1);
        tx = dco_ofdm_tx(bits,params,modulation,pilotIdx,pilotSymbols);
        yClean = conv(tx.waveform,h);
        yClean = yClean(1:numel(tx.waveform));
        [y,noVar] = add_shot_noise(yClean,snrDb,params,params.vlc.Hdc);
        Y = fft(y(params.cpLen+1:params.cpLen+params.NFFT),params.NFFT);
        [Ypilot,Xpilot] = extract_pilots(Y,tx.freqGrid,pilotIdx,params);
        HpilotLs = Ypilot(:)./(Xpilot(:)+eps);
        estimates = cell(1,numMethods);
        estimates{1} = ls_estimator(HpilotLs,pilotIdx,params.numActive);
        estimates{2} = mmse_estimator(HpilotLs,pilotIdx,params.numActive,params.NFFT,L,noVar);
        next = 3;
        if any(strcmp(methods,'CNN'))
            xNet = single([real(HpilotLs(:)).' imag(HpilotLs(:)).']);
            yNet = predict(cnn,{reshape(xNet,1,[])});
            estimates{next} = local_vector_to_complex(yNet); next = next + 1;
        end
        if any(strcmp(methods,'DRN'))
            xNet = single([real(HpilotLs(:)).' imag(HpilotLs(:)).']);
            yNet = predict(drn,xNet);
            estimates{next} = local_vector_to_complex(yNet);
        end
        for m = 1:numMethods
            Hest = estimates{m};
            mseAcc(frame,m) = calculate_mse(Htrue,Hest);
            nmseAcc(frame,m) = calculate_nmse(Htrue,Hest);
            rx = dco_ofdm_rx(y,params,modulation,Hest,tx);
            berAcc(frame,m) = calculate_ber(tx.bits,rx.bits);
        end
        if is == ceil(numSnr*0.7) && frame == 1
            example.Htrue = Htrue;
            example.estimates = estimates;
            example.methods = methods;
            example.snrDb = snrDb;
            example.modulation = string(modulation);
        end
    end
    mse(is,:) = mean(mseAcc,1);
    nmse(is,:) = mean(nmseAcc,1);
    ber(is,:) = mean(berAcc,1);
    for m = 1:numMethods
        se(is,m) = calculate_spectral_efficiency(snrDb,mse(is,m));
    end
end
result = struct();
result.modulation = string(modulation);
result.methods = string(methods);
result.snrDb = params.snrDbRange(:);
result.mse = mse;
result.nmse = nmse;
result.ber = ber;
result.se = se;
result.example = example;
result.mseTable = array2table([result.snrDb mse],'VariableNames',[{'SNR_dB'},methods]);
result.nmseTable = array2table([result.snrDb nmse],'VariableNames',[{'SNR_dB'},methods]);
result.berTable = array2table([result.snrDb ber],'VariableNames',[{'SNR_dB'},methods]);
result.seTable = array2table([result.snrDb se],'VariableNames',[{'SNR_dB'},methods]);
end

function bps = local_bits_per_symbol(modulation)
if strcmpi(string(modulation),'QPSK'), bps = 2; elseif strcmpi(string(modulation),'16QAM'), bps = 4; else, error('Unsupported modulation.'); end
end

function H = local_vector_to_complex(y)
y = gather(y);
y = double(reshape(y,1,[]));
N = numel(y)/2;
H = y(1:N).' + 1j*y(N+1:end).';
end
