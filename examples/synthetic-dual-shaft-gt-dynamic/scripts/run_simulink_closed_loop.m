%RUN_SIMULINK_CLOSED_LOOP Run the exploratory Simulink closed-loop case.

thisFile = mfilename('fullpath');
packageRoot = fileparts(fileparts(thisFile));
addpath(fullfile(packageRoot, 'scripts'));
addpath(fullfile(packageRoot, 'src'));

build_gt_simulink_model();
GT_SIM = init_gt_simulink_workspace();

model = 'GT_DualShaft_Dynamic_Exploratory';
modelPath = fullfile(packageRoot, 'simulink', [model '.slx']);
open_system(modelPath);

tic;
simOut = sim(model, 'StopTime', num2str(GT_SIM.stop_time_s));
elapsed_s = toc;

plant_diag = simOut.get('plant_diag');
fuel_cmd = simOut.get('fuel_cmd');
speed_error_rel = simOut.get('speed_error_rel');
pdc_load = simOut.get('pdc_load');

time_s = plant_diag.Time(:);
N_GG_rpm = plant_diag.Data(:, 1);
N_PT_rpm = plant_diag.Data(:, 2);
T3_K = plant_diag.Data(:, 5);
map_valid = plant_diag.Data(:, 10);
speed_error_rpm = speed_error_rel.Data(:)*GT_SIM.N_PT_ref_rpm;
after_step = time_s >= GT_SIM.load_step_time_s;

max_speed_error_after_step_rpm = max(abs(speed_error_rpm(after_step)));
final_speed_error_rpm = speed_error_rpm(end);
all_map_valid = all(map_valid >= 0.5);
T3_design_not_exceeded = max(T3_K) <= ...
    GT_SIM.GT.limits.T3_design_K + GT_SIM.temperature_limit_tol_K;
speed_final_ok = abs(final_speed_error_rpm) <= ...
    GT_SIM.final_speed_error_rpm;

fprintf('Validation case: %s\n', GT_SIM.validation_case);
fprintf('Solver: %s, fixed step: %.4f s\n', get_param(model, 'Solver'), ...
    GT_SIM.fixed_step_s);
fprintf('Simulation elapsed: %.3f s\n', elapsed_s);
fprintf('Samples: %d\n', numel(time_s));
fprintf('Pdc load range: %.3f / %.3f MW\n', min(pdc_load.Data(:))/1e6, ...
    max(pdc_load.Data(:))/1e6);
fprintf('N_PT initial/final: %.6f / %.6f rpm\n', N_PT_rpm(1), ...
    N_PT_rpm(end));
fprintf('N_PT min/max: %.6f / %.6f rpm\n', min(N_PT_rpm), max(N_PT_rpm));
fprintf('Max speed error after step: %.6f rpm\n', ...
    max_speed_error_after_step_rpm);
fprintf('Final speed error: %.6f rpm\n', final_speed_error_rpm);
fprintf('N_GG min/max: %.6f / %.6f rpm\n', min(N_GG_rpm), max(N_GG_rpm));
fprintf('T3 min/max: %.6f / %.6f K\n', min(T3_K), max(T3_K));
fprintf('Fuel command min/max: %.6f / %.6f kg/s\n', ...
    min(fuel_cmd.Data(:)), max(fuel_cmd.Data(:)));
fprintf('All map valid samples: %d\n', all_map_valid);
fprintf('T3 design not exceeded: %d\n', T3_design_not_exceeded);
fprintf('Final speed error ok: %d\n', speed_final_ok);
fprintf('Closed-loop validation passed: %d\n', all_map_valid && ...
    T3_design_not_exceeded && speed_final_ok);
