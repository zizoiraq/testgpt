function plot_complexity(complexityTable,params)
%PLOT_COMPLEXITY Complexity comparison across estimators.
base = complexityTable(complexityTable.Modulation==complexityTable.Modulation(1),:);
f = figure('Color','w','Position',[100 100 820 520]);
tiledlayout(1,2,'TileSpacing','compact');
nexttile; bar(categorical(base.Method),base.ParameterCount); ylabel('Parameters'); title('Model Size'); grid on;
nexttile; bar(categorical(base.Method),base.InferenceTimeSecondsPerFrame*1e3); ylabel('Inference Time (ms/frame)'); title('Inference Latency'); grid on;
set(findall(f,'Type','axes'),'FontName','Times New Roman','FontSize',12);
exportgraphics(f,fullfile(params.resultsDir,'Figure7_Complexity.png'),'Resolution',300);
end
