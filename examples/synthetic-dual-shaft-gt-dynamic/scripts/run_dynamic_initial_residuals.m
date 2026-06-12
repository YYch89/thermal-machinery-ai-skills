%RUN_DYNAMIC_INITIAL_RESIDUALS Print dynamic initial-condition residuals.

thisFile = mfilename('fullpath');
packageRoot = fileparts(fileparts(thisFile));
dataRoot = fileparts(packageRoot);
addpath(fullfile(packageRoot, 'src'));

GT = build_gt_model_data();
ic = build_gt_dynamic_initial_condition(GT);
[xdot, y] = evaluate_gt_dynamics(0, ic.x0, ic.u0, GT, dataRoot);

fprintf('Stage: %s\n', y.stage);
fprintf('Load mode: %s\n', y.load.mode);
fprintf('Compressor map valid: %d\n', y.compressor.map_valid);
fprintf('domega_GG: %.3e rad/s^2\n', xdot(1));
fprintf('domega_PT: %.3e rad/s^2\n', xdot(2));
fprintf('dP3: %.3e Pa/s\n', xdot(3));
fprintf('dP4: %.3e Pa/s\n', xdot(4));
fprintf('dT3: %.3e K/s\n', xdot(5));
fprintf('dWf_act: %.3e kg/s^2\n', xdot(6));
fprintf('P3 flow residual: %.3e\n', y.residuals.P3_flow_rel);
fprintf('P4 flow residual: %.3e\n', y.residuals.P4_flow_rel);
fprintf('GG power residual: %.3e\n', y.residuals.GG_power_balance_rel);
fprintf('PT power residual: %.3e\n', y.residuals.PT_power_balance_rel);
fprintf('T3 equilibrium residual: %.3e\n', y.residuals.T3_eq_rel);
fprintf('Fuel actuator residual: %.3e\n', y.residuals.fuel_actuator_rel);
fprintf('All dynamic initial checks passed: %d\n', y.checks.all_passed);
