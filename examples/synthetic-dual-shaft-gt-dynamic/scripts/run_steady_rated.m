%RUN_STEADY_RATED Print the rated steady map-wrapper closure summary.

thisFile = mfilename('fullpath');
packageRoot = fileparts(fileparts(thisFile));
dataRoot = fileparts(packageRoot);
addpath(fullfile(packageRoot, 'src'));

GT = build_gt_model_data();
steady = evaluate_gt_steady_rated(GT, dataRoot);

fprintf('Stage: %s\n', steady.stage);
fprintf('Compressor map source: %s\n', steady.compressor.map_source);
fprintf('Compressor map valid: %d\n', steady.compressor.map_valid);
fprintf('Compressor air flow: %.6f kg/s\n', ...
    steady.compressor.W_air_kgps);
fprintf('Combustor T3: %.6f K\n', steady.combustor.T3_K);
fprintf('TG Stodola flow residual: %.3e\n', ...
    steady.residuals.TG_flow_rel);
fprintf('PT Stodola flow residual: %.3e\n', ...
    steady.residuals.PT_flow_rel);
fprintf('GG power residual: %.3e\n', ...
    steady.residuals.GG_power_balance_rel);
fprintf('PT power residual: %.3e\n', ...
    steady.residuals.PT_power_balance_rel);
fprintf('DC power residual: %.3e\n', steady.residuals.DC_power_rel);
fprintf('All steady checks passed: %d\n', steady.checks.all_passed);
