function plot_nmse(results,params)
%PLOT_NMSE Publication-quality NMSE vs SNR.
mods = fieldnames(results);
for k=1:numel(mods)
    r = results.(mods{k}); f = figure('Color','w','Position',[100 100 760 520]); hold on; grid on; box on;
    for m=1:numel(r.methods), semilogy(r.snrDb,r.nmse(:,m),'-s','LineWidth',1.8,'MarkerSize',6); end
    xlabel('SNR (dB)'); ylabel('NMSE'); title(['NMSE vs SNR - ' mods{k}]); legend(r.methods,'Location','southwest'); set(gca,'FontName','Times New Roman','FontSize',12);
    exportgraphics(f,fullfile(params.resultsDir,['Figure2_NMSE_' mods{k} '.png']),'Resolution',300);
end
end
