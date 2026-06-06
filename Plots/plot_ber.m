function plot_ber(results,params)
%PLOT_BER Publication-quality BER vs SNR.
mods = fieldnames(results);
for k=1:numel(mods)
    r = results.(mods{k}); f = figure('Color','w','Position',[100 100 760 520]); hold on; grid on; box on;
    for m=1:numel(r.methods), semilogy(r.snrDb,max(r.ber(:,m),1e-5),'-^','LineWidth',1.8,'MarkerSize',6); end
    xlabel('SNR (dB)'); ylabel('BER'); title(['BER vs SNR - ' mods{k}]); legend(r.methods,'Location','southwest'); set(gca,'FontName','Times New Roman','FontSize',12);
    exportgraphics(f,fullfile(params.resultsDir,['Figure3_BER_' mods{k} '.png']),'Resolution',300);
end
end
