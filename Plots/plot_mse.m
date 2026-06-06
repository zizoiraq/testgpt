function plot_mse(results,params)
%PLOT_MSE Publication-quality MSE vs SNR.
mods = fieldnames(results);
for k=1:numel(mods)
    r = results.(mods{k});
    f = figure('Color','w','Position',[100 100 760 520]); hold on; grid on; box on;
    for m=1:numel(r.methods), semilogy(r.snrDb,r.mse(:,m),'-o','LineWidth',1.8,'MarkerSize',6); end
    xlabel('SNR (dB)'); ylabel('MSE'); title(['MSE vs SNR - ' mods{k}]); legend(r.methods,'Location','southwest'); set(gca,'FontName','Times New Roman','FontSize',12);
    exportgraphics(f,fullfile(params.resultsDir,['Figure1_MSE_' mods{k} '.png']),'Resolution',300);
end
end
