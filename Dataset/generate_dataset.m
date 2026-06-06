function data = generate_dataset(params,numTrain,numValidation,numTest,pilotIdx,L,modulation)
%GENERATE_DATASET Generate supervised pilot-observation/channel-response data.
numTotal = numTrain + numValidation + numTest;
inputSize = 2*numel(pilotIdx);
outputSize = 2*params.numActive;
X = zeros(numTotal,inputSize,'single');
Y = zeros(numTotal,outputSize,'single');
for n = 1:numTotal
    [~,Hactive] = generate_vlc_channel(params,L);
    snrDb = params.snrDbRange(randi(numel(params.snrDbRange)));
    pilotSymbols = ones(numel(pilotIdx),1);
    cleanPilots = Hactive(pilotIdx).*pilotSymbols;
    signalPower = mean(abs(cleanPilots).^2);
    awgnVariance = signalPower/10^(snrDb/10);
    shotVariance = 2*params.vlc.q*(params.vlc.R*params.vlc.Hdc + params.vlc.Ibg)*params.vlc.B;
    sigma2 = awgnVariance + shotVariance;
    Ypilot = cleanPilots + sqrt(sigma2/2)*(randn(size(cleanPilots))+1j*randn(size(cleanPilots)));
    HpilotLs = Ypilot ./ pilotSymbols;
    X(n,:) = single([real(HpilotLs(:)).' imag(HpilotLs(:)).']);
    Y(n,:) = single([real(Hactive(:)).' imag(Hactive(:)).']);
end
data = struct();
data.XTrain = X(1:numTrain,:);
data.YTrain = Y(1:numTrain,:);
data.XValidation = X(numTrain+1:numTrain+numValidation,:);
data.YValidation = Y(numTrain+1:numTrain+numValidation,:);
data.XTest = X(numTrain+numValidation+1:end,:);
data.YTest = Y(numTrain+numValidation+1:end,:);
data.pilotIdx = pilotIdx(:);
data.channelTaps = L;
data.modulation = string(modulation);
end
