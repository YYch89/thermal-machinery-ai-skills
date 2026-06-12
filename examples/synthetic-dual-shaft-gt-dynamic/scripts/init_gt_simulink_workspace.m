function GT_SIM = init_gt_simulink_workspace()
%INIT_GT_SIMULINK_WORKSPACE Initialize workspace variables for Simulink.

thisFile = mfilename('fullpath');
packageRoot = fileparts(fileparts(thisFile));
dataRoot = packageRoot;
srcRoot = fullfile(packageRoot, 'src');
cacheRoot = fullfile(packageRoot, 'simulink', 'cache');
codegenRoot = fullfile(packageRoot, 'simulink', 'codegen');
addpath(srcRoot);
if ~isfolder(cacheRoot)
    mkdir(cacheRoot);
end
if ~isfolder(codegenRoot)
    mkdir(codegenRoot);
end
Simulink.fileGenControl('set', 'CacheFolder', cacheRoot, ...
    'CodeGenFolder', codegenRoot);

GT = build_gt_model_data();
ic = build_gt_dynamic_initial_condition(GT);

GT_SIM = struct();
GT_SIM.packageRoot = packageRoot;
GT_SIM.dataRoot = dataRoot;
GT_SIM.cacheRoot = cacheRoot;
GT_SIM.codegenRoot = codegenRoot;
GT_SIM.GT = GT;
GT_SIM.ic = ic;
GT_SIM.x0 = ic.x0;
GT_SIM.u0 = ic.u0;
GT_SIM.comp = build_component_workspace(GT, dataRoot);
GT_SIM.Wf0_kgps = ic.u0.Wf_cmd_kgps;
GT_SIM.Wf_min_kgps = GT.limits.Wf_min_kgps;
GT_SIM.Wf_max_kgps = GT.limits.Wf_max_normal_kgps;
GT_SIM.N_PT_ref_rpm = GT.req.N_PT0_rpm;
GT_SIM.int_e0 = GT.init.int_e_N0;
GT_SIM.Kp_fuel = GT.dyn.Kp_N;
GT_SIM.Ki_fuel = GT.dyn.Ki_N_per_s;
GT_SIM.Pdc0_W = GT.req.P_dc_rated_W;
GT_SIM.Pdc_step_W = 0.95*GT.req.P_dc_rated_W;
GT_SIM.load_step_time_s = 2.0;
GT_SIM.stop_time_s = 8.0;
GT_SIM.component_long_stop_time_s = 60.0;
GT_SIM.fixed_step_s = 0.01;
GT_SIM.validation_case = 'rated_to_95_percent_load_rejection';
GT_SIM.max_speed_error_rpm = 50;
GT_SIM.final_speed_error_rpm = 10;
GT_SIM.initial_speed_tol_rpm = 1e-5;
GT_SIM.initial_temperature_tol_K = 1e-3;
GT_SIM.temperature_limit_tol_K = 1e-2;

assignin('base', 'GT_SIM', GT_SIM);
end

function comp = build_component_workspace(GT, dataRoot)
audit = audit_gt_maps(dataRoot);
pi_bp = linspace(audit.compressor.xpi.u_col_min(1), ...
    audit.compressor.xpi.u_col_max(1), 120)';
N_bp = linspace(audit.compressor.xpi.u_col_min(2), ...
    audit.compressor.xpi.u_col_max(2), 50)';
pi_min_by_N = repmat(min(pi_bp), size(N_bp));
pi_max_by_N = repmat(max(pi_bp), size(N_bp));
[PI, NN] = ndgrid(pi_bp, N_bp);
W_table = zeros(size(PI));
valid_table = zeros(size(PI));
for k = 1:numel(PI)
    map = evaluate_compressor_xpi_map(audit.compressor.files.xpi, ...
        PI(k), NN(k));
    W_table(k) = map.W_map_rel;
    valid_table(k) = double(map.valid);
end

comp = struct();
comp.P1_Pa = GT.design.state.P1_Pa;
comp.T1_K = GT.design.state.T1_K;
comp.P5_Pa = GT.design.state.P5_Pa;
comp.omega_GG0_radps = GT.init.omega_GG0_radps;
comp.omega_PT0_radps = GT.init.omega_PT0_radps;
comp.eta_chain = GT.req.eta_gen*GT.req.eta_rect;
comp.air_exp = (GT.assump.gamma_air - 1)/GT.assump.gamma_air;
comp.gas_exp = (GT.assump.gamma_gas - 1)/GT.assump.gamma_gas;
comp.compressor.pi_bp = pi_bp;
comp.compressor.N_bp = N_bp;
comp.compressor.pi_min_by_N = pi_min_by_N;
comp.compressor.pi_max_by_N = pi_max_by_N;
comp.compressor.W_map_table = W_table;
comp.compressor.valid_table = valid_table;
comp.compressor.pi_min = min(pi_bp);
comp.compressor.pi_max = max(pi_bp);
comp.compressor.N_min = min(N_bp);
comp.compressor.N_max = max(N_bp);
comp.compressor.local_s_pi = GT.mapScale.compressor.local_s_pi;
comp.compressor.local_s_W = GT.mapScale.compressor.local_s_W;
comp.compressor.eta_c = GT.mapScale.compressor.local_eta_map_dp * ...
    GT.mapScale.compressor.local_s_eta;
comp.compressor.pi_floor = 1.001;
end
