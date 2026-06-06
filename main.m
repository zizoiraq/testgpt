%% Deep Residual Learning-Based Channel Estimation for DCO-OFDM VLC Systems Under Shot Noise
% MATLAB R2024a complete research framework
clear; clc; close all;
rng(42,"twister");
addpath(genpath(pwd));

params = struct();
params.NFFT = 64;
params.cpLen = 16;
params.activeBins = 2:(params.NFFT/2);       % positive-frequency data/pilot bins, excluding DC
params.numActive = numel(params.activeBins);
params.snrDbRange = -5:2:30;
params.pilotSets = struct("A",4,"B",8,"C",16);
params.defaultPilotSet = "B";
params.defaultPilotCount = params.pilotSets.(params.defaultPilotSet);
params.channelTaps = [4 8 16];
params.defaultChannelTaps = 8;
params.modulations = ["QPSK","16QAM"];
params.dcBias = 3.0;
params.clipMin = 0;
params.clipMax = Inf;
params.numFramesEval = 350;
params.numChannelExamples = 2500;
params.dataset.numTrain = 60000;
params.dataset.numValidation = 10000;
params.dataset.numTest = 10000;
params.training.maxEpochs = 80;
params.training.miniBatchSize = 512;
params.training.initialLearnRate = 1e-3;
params.training.gradientThreshold = 1.0;
params.training.l2Regularization = 1e-4;
params.training.learnRateDropPeriod = 20;
params.training.learnRateDropFactor = 0.5;
params.training.validationPatience = Inf;
params.vlc = struct("m",1,"Adet",1e-4,"distance",2.5,"phiDeg",30,"psiDeg",20, ...
    "FOVDeg",60,"Ts",1,"n",1.5,"q",1.6e-19,"R",0.53,"Ibg",5100e-6,"B",200e6);
params.vlc.Hdc = lambertian_gain(params.vlc.m,params.vlc.Adet,params.vlc.distance, ...
    params.vlc.phiDeg,params.vlc.psiDeg,params.vlc.FOVDeg,params.vlc.Ts,params.vlc.n);
params.resultsDir = fullfile(pwd,"Results");
if ~exist(params.resultsDir,"dir"), mkdir(params.resultsDir); end

fprintf("Deep Residual Learning-Based Channel Estimation for DCO-OFDM VLC under Shot Noise\n");
fprintf("Hdc = %.4e, NFFT = %d, CP = %d\n",params.vlc.Hdc,params.NFFT,params.cpLen);

pilotIdx = round(linspace(1,params.numActive,params.defaultPilotCount));
trained = struct();
complexityRows = [];

for imod = 1:numel(params.modulations)
    modulation = params.modulations(imod);
    modField = matlab.lang.makeValidName(char(modulation));
    fprintf("\nPreparing %s data set with %d pilots...\n",modulation,params.defaultPilotCount);
    data = generate_dataset(params,params.dataset.numTrain,params.dataset.numValidation, ...
        params.dataset.numTest,pilotIdx,params.defaultChannelTaps,modulation);

    fprintf("Training CNN benchmark (%s)...\n",modulation);
    tStart = tic;
    cnn = train_cnn(data.XTrain,data.YTrain,data.XValidation,data.YValidation,params);
    cnnTrainTime = toc(tStart);

    fprintf("Training proposed DRN (%s)...\n",modulation);
    tStart = tic;
    drn = train_drn(data.XTrain,data.YTrain,data.XValidation,data.YValidation,params);
    drnTrainTime = toc(tStart);

    trained.(modField).cnn = cnn;
    trained.(modField).drn = drn;
    trained.(modField).pilotIdx = pilotIdx;
    trained.(modField).testData = data;

    fprintf("Evaluating estimators (%s)...\n",modulation);
    results.(modField) = evaluate_models(params,modulation,pilotIdx,params.defaultChannelTaps,cnn,drn);

    cTable = local_complexity_table(params,cnn,drn,cnnTrainTime,drnTrainTime,data.XTest);
    cTable.Modulation = repmat(modulation,height(cTable),1);
    complexityRows = [complexityRows; cTable]; %#ok<AGROW>
end

fprintf("\nRunning pilot density and channel-tap studies...\n");
referenceMod = "QPSK";
pilotAnalysis = struct();
pilotNames = fieldnames(params.pilotSets);
for i = 1:numel(pilotNames)
    pName = pilotNames{i};
    pCount = params.pilotSets.(pName);
    pIdx = round(linspace(1,params.numActive,pCount));
    pilotAnalysis.(pName) = evaluate_models(params,referenceMod,pIdx,params.defaultChannelTaps,[],[],"classicalOnly",true);
end
channelComplexity = struct();
for L = params.channelTaps
    channelComplexity.(sprintf("L%d",L)) = evaluate_models(params,referenceMod,pilotIdx,L,[],[],"classicalOnly",true);
end

resultMods = fieldnames(results);
for im = 1:numel(resultMods)
    modName = resultMods{im};
    writetable(results.(modName).mseTable,fullfile(params.resultsDir,"Table1_MSE_" + modName + ".csv"));
    writetable(results.(modName).nmseTable,fullfile(params.resultsDir,"Table2_NMSE_" + modName + ".csv"));
    writetable(results.(modName).berTable,fullfile(params.resultsDir,"Table3_BER_" + modName + ".csv"));
    writetable(results.(modName).seTable,fullfile(params.resultsDir,"Table4_SE_" + modName + ".csv"));
end
writetable(complexityRows,fullfile(params.resultsDir,"Table5_Complexity.csv"));

plot_mse(results,params);
plot_nmse(results,params);
plot_ber(results,params);
plot_se(results,params);
plot_pilot_analysis(pilotAnalysis,params);
plot_channel_complexity(channelComplexity,params);
plot_complexity(complexityRows,params);
plot_channel_example(results.QPSK.example,params);

display_summary(results,complexityRows,params);
save(fullfile(params.resultsDir,"complete_results.mat"),"results","pilotAnalysis","channelComplexity","complexityRows","params","-v7.3");
fprintf("\nAll simulations completed. Results saved in %s\n",params.resultsDir);

function cTable = local_complexity_table(params,cnn,drn,cnnTrainTime,drnTrainTime,XTest)
methods = ["LS";"MMSE";"CNN";"DRN"];
paramCount = [0; 0; local_count_params(cnn); local_count_params(drn)];
trainingTime = [0; 0; cnnTrainTime; drnTrainTime];
memMB = paramCount*4/1024^2;
inferenceTime = zeros(4,1);
numObs = min(1000,size(XTest,1));
X = XTest(1:numObs,:);
LSdummy = randn(params.numActive,params.defaultPilotCount)+1j*randn(params.numActive,params.defaultPilotCount);
Hpilot = randn(params.defaultPilotCount,1)+1j*randn(params.defaultPilotCount,1);
t = tic; for k=1:numObs, ls_estimator(Hpilot,round(linspace(1,params.numActive,params.defaultPilotCount)),params.numActive); end; inferenceTime(1)=toc(t)/numObs;
t = tic; for k=1:numObs, mmse_estimator(Hpilot,round(linspace(1,params.numActive,params.defaultPilotCount)),params.numActive,params.NFFT,params.defaultChannelTaps,1e-3); end; inferenceTime(2)=toc(t)/numObs;
t = tic; predict(cnn,local_cnn_cells(X)); inferenceTime(3)=toc(t)/numObs;
t = tic; predict(drn,X); inferenceTime(4)=toc(t)/numObs;
cTable = table(methods,paramCount,trainingTime,inferenceTime,memMB,'VariableNames', ...
    {'Method','ParameterCount','TrainingTimeSeconds','InferenceTimeSecondsPerFrame','MemoryMB'});
end

function n = local_count_params(net)
n = 0;
if isempty(net), return; end
learnables = net.Layers;
for i=1:numel(learnables)
    props = properties(learnables(i));
    for p = 1:numel(props)
        val = learnables(i).(props{p});
        if isnumeric(val) && ~isempty(val) && (contains(props{p},"Weights") || contains(props{p},"Bias") || contains(props{p},"Scale") || contains(props{p},"Offset"))
            n = n + numel(val);
        end
    end
end
end

function C = local_cnn_cells(X)
C = cell(size(X,1),1);
for i=1:size(X,1), C{i}=reshape(X(i,:),1,[]); end
end
