function layers = build_cnn(inputSize,outputSize)
%BUILD_CNN One-dimensional convolutional neural benchmark for channel estimation.
layers = [
    sequenceInputLayer(1,'Name','input','Normalization','zscore')
    convolution1dLayer(3,32,'Padding','same','Name','conv1')
    reluLayer('Name','relu1')
    convolution1dLayer(3,64,'Padding','same','Name','conv2')
    reluLayer('Name','relu2')
    flattenLayer('Name','flatten')
    fullyConnectedLayer(outputSize,'Name','fc_output')
    regressionLayer('Name','regression')];
if inputSize < 3
    warning('CNN input size is short; convolution uses same padding.');
end
end
