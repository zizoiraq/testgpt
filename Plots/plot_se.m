function plot_se(results,params)
%PLOT_SE Publication-quality spectral-efficiency plot.
mods = fieldnames(results);
for k=1:numel(mods)
    r = results.(mods{k}); f = figure('Color','w','Position',[100 100 760 520]); hold on; grid on; box on;
    for m=1:numel(r.methods), plot(r.snrDb,r.se(:,m),'-d','LineWidth',1.8,'MarkerSize',6); end
    xlabel('SNR (dB)'); ylabel('Spectral Efficiency (bits/s/Hz)'); title(['Spectral Efficiency vs SNR - ' mods{k}]); legend(r.methods,'Location','northwest'); set(gca,'FontName','Times New Roman','FontSize',12);
    exportgraphics(f,fullfile(params.resultsDir,['Figure4_SE_' mods{k} '.png']),'Resolution',300);
end
end
