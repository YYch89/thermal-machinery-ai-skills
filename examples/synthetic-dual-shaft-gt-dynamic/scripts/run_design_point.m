%RUN_DESIGN_POINT Print the current gas turbine design-point summary.
%
% Run from this folder or from the package root.

thisFile = mfilename('fullpath');
packageRoot = fileparts(fileparts(thisFile));
addpath(fullfile(packageRoot, 'src'));

GT = build_gt_model_data();

fprintf('Model level: %s\n', GT.req.model_level);
fprintf('DC rated power: %.3f MW\n', GT.req.P_dc_rated_W/1e6);
fprintf('Power-turbine shaft power: %.3f MW\n', GT.req.P_PT_shaft0_W/1e6);
fprintf('Nominal compressor pressure ratio: %.3f\n', GT.design.pi_c);
fprintf('Air flow: %.3f kg/s\n', GT.design.state.W_air_kgps);
fprintf('Fuel flow: %.4f kg/s\n', GT.design.state.W_fuel_kgps);
fprintf('Fuel-air ratio: %.5f\n', GT.design.perf.fuel_air_ratio);
fprintf('T3: %.2f K\n', GT.design.state.T3_K);
fprintf('P3: %.3f MPa\n', GT.design.state.P3_Pa/1e6);
fprintf('P4: %.3f kPa\n', GT.design.state.P4_Pa/1e3);
fprintf('PT load torque: %.2f kN*m\n', GT.init.Tload0_Nm/1e3);
fprintf('DC thermal efficiency: %.2f %%\n', 100*GT.design.perf.eta_dc);
fprintf('All checks passed: %d\n', GT.checks.all_passed);
