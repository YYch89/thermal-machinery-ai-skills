%RUN_MAP_AUDIT Print a compact read-only map audit summary.

thisFile = mfilename('fullpath');
packageRoot = fileparts(fileparts(thisFile));
addpath(fullfile(packageRoot, 'src'));

audit = audit_gt_maps();

fprintf('Compressor primary: %s\n', audit.compressor.primary);
fprintf('Compressor fallback: %s\n', audit.compressor.fallback);
fprintf('Compressor xpi file exists: %d\n', audit.compressor.xpi.exists);
fprintf('Compressor local efficiency source: %s\n', audit.compressor.efficiency_source);
fprintf('Compressor design pi_map: %.5f\n', audit.compressor.design.pi_map);
fprintf('Compressor map valid at design: %d\n', audit.compressor.map_valid_at_design);
fprintf('Turbine primary: %s\n', audit.turbine.primary);
fprintf('K_TG: %.8g\n', audit.turbine.K_TG);
fprintf('K_PT: %.8g\n', audit.turbine.K_PT);
fprintf('Ready for Steady_Map_Rated: %d\n', audit.summary.ready_for_steady_map_rated);
