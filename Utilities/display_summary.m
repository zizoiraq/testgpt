function display_summary(results,complexityTable,params)
%DISPLAY_SUMMARY Print final numerical result tables and complexity analysis.
fprintf('\n================ FINAL SUMMARY ================\n');
mods = fieldnames(results);
for i=1:numel(mods)
    r = results.(mods{i});
    fprintf('\nModulation: %s\n',mods{i});
    disp(r.mseTable);
    disp(r.nmseTable);
    disp(r.berTable);
    disp(r.seTable);
end
fprintf('\nComplexity Analysis\n');
disp(complexityTable);
fprintf('Figures and CSV tables were exported at 300 dpi to: %s\n',params.resultsDir);
fprintf('Terminology: the proposed method is consistently reported as DRN / deep residual learning-based estimator.\n');
end
