function plot_channel_complexity(channelComplexity,params)
%PLOT_CHANNEL_COMPLEXITY Effect of number of multipath channel taps.
names = fieldnames(channelComplexity); f = figure('Color','w','Position',[100 100 760 520]); hold on; grid on; box on;
for i=1:numel(names)
    r = channelComplexity.(names{i}); idx = find(r.methods=='MMSE',1); semilogy(r.snrDb,r.nmse(:,idx),'-o','LineWidth',1.8,'MarkerSize',6,'DisplayName',strrep(names{i},'L','L = '));
end
xlabel('SNR (dB)'); ylabel('NMSE'); title('Effect of Number of Channel Taps'); legend('Location','southwest'); set(gca,'FontName','Times New Roman','FontSize',12);
exportgraphics(f,fullfile(params.resultsDir,'Figure6_Channel_Taps.png'),'Resolution',300);
end
