function plot_channel_example(example,params)
%PLOT_CHANNEL_EXAMPLE Channel magnitude estimation example.
f = figure('Color','w','Position',[100 100 800 540]); hold on; grid on; box on;
plot(1:numel(example.Htrue),abs(example.Htrue),'k-','LineWidth',2.2,'DisplayName','True Channel');
for m=1:numel(example.methods)
    plot(1:numel(example.estimates{m}),abs(example.estimates{m}),'--','LineWidth',1.6,'DisplayName',char(example.methods(m)));
end
xlabel('Active Subcarrier Index'); ylabel('|H(k)|'); title(sprintf('Channel Estimation Example at %g dB (%s)',example.snrDb,example.modulation)); legend('Location','best'); set(gca,'FontName','Times New Roman','FontSize',12);
exportgraphics(f,fullfile(params.resultsDir,'Figure8_Channel_Example.png'),'Resolution',300);
end
