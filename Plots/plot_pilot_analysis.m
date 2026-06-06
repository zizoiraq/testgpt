function plot_pilot_analysis(pilotAnalysis,params)
%PLOT_PILOT_ANALYSIS Compare pilot densities using MMSE NMSE.
names = fieldnames(pilotAnalysis); f = figure('Color','w','Position',[100 100 760 520]); hold on; grid on; box on;
for i=1:numel(names)
    r = pilotAnalysis.(names{i}); idx = find(r.methods=='MMSE',1); semilogy(r.snrDb,r.nmse(:,idx),'-o','LineWidth',1.8,'MarkerSize',6,'DisplayName',[names{i} ' (' num2str(params.pilotSets.(names{i})) ' pilots)']);
end
xlabel('SNR (dB)'); ylabel('NMSE'); title('Pilot Density Analysis'); legend('Location','southwest'); set(gca,'FontName','Times New Roman','FontSize',12);
exportgraphics(f,fullfile(params.resultsDir,'Figure5_Pilot_Density.png'),'Resolution',300);
end
