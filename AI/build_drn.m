function lgraph = build_drn(inputSize,outputSize)
%BUILD_DRN Proposed deep residual network for pilot-aided channel estimation.
lgraph = layerGraph();
baseLayers = [
    featureInputLayer(inputSize,'Name','input','Normalization','zscore')
    fullyConnectedLayer(128,'Name','fc_in')
    reluLayer('Name','relu_in')];
lgraph = addLayers(lgraph,baseLayers);
previous = 'relu_in';
for b = 1:3
    prefix = sprintf('res%d',b);
    blockLayers = [
        fullyConnectedLayer(128,'Name',[prefix '_fc1'])
        reluLayer('Name',[prefix '_relu1'])
        dropoutLayer(0.1,'Name',[prefix '_dropout'])
        fullyConnectedLayer(128,'Name',[prefix '_fc2'])];
    add = additionLayer(2,'Name',[prefix '_add']);
    norm = layerNormalizationLayer('Name',[prefix '_layernorm']);
    relu = reluLayer('Name',[prefix '_relu_out']);
    lgraph = addLayers(lgraph,blockLayers);
    lgraph = addLayers(lgraph,add);
    lgraph = addLayers(lgraph,norm);
    lgraph = addLayers(lgraph,relu);
    lgraph = connectLayers(lgraph,previous,[prefix '_fc1']);
    lgraph = connectLayers(lgraph,[prefix '_fc2'],[prefix '_add/in1']);
    lgraph = connectLayers(lgraph,previous,[prefix '_add/in2']);
    lgraph = connectLayers(lgraph,[prefix '_add'],[prefix '_layernorm']);
    lgraph = connectLayers(lgraph,[prefix '_layernorm'],[prefix '_relu_out']);
    previous = [prefix '_relu_out'];
end
outputLayers = [
    fullyConnectedLayer(outputSize,'Name','fc_output')
    regressionLayer('Name','regression')];
lgraph = addLayers(lgraph,outputLayers);
lgraph = connectLayers(lgraph,previous,'fc_output');
end
