function GT = build_gt_model_data()
%BUILD_GT_MODEL_DATA Build the design-point data package for the gas turbine.
%
% The model is an exploratory/reduced dual-shaft free-power-turbine gas
% turbine for a generic 16 MW islanded DC microgrid generator set. This function is
% intended to be the single MATLAB data source for later Simulink models.

req = define_requirements();
assump = define_assumptions();
sweep = sweep_pressure_ratio(req, assump, 8:2:22);
design = solve_design_point(req, assump, req.pi_c_nominal);
mapScale = build_map_scaling(design, req, assump);
dyn = define_dynamic_params(design, req, assump);
init = build_initial_conditions(design, dyn, req);
limits = define_limits(design, req);
checks = run_design_checks(design, mapScale, dyn, init, limits, req);

GT = struct( ...
    'req', req, ...
    'assump', assump, ...
    'sweep', sweep, ...
    'design', design, ...
    'mapScale', mapScale, ...
    'dyn', dyn, ...
    'init', init, ...
    'limits', limits, ...
    'checks', checks);

end

function req = define_requirements()
req.application = 'islanded_dc_microgrid';
req.architecture = 'dual_shaft_free_power_turbine';
req.model_boundary = 'gas_turbine_with_equivalent_load';
req.control_objective = 'power_turbine_speed_control';
req.model_level = 'exploratory_reduced';

req.P_dc_rated_W = 16e6;
req.T3_design_K = 1440;
req.Tamb_K = 288.15;
req.Pamb_Pa = 101.325e3;
req.fuel = 'generic liquid fuel';

req.pi_c_nominal = 14;
req.N_GG0_rpm = 12000;
req.N_PT0_rpm = 3000;

req.eta_gen = 0.96;
req.eta_rect = 0.98;
req.P_PT_shaft0_W = req.P_dc_rated_W/(req.eta_gen*req.eta_rect);
end

function assump = define_assumptions()
assump.cp_air_J_kgK = 1005;
assump.gamma_air = 1.4;
assump.R_air_J_kgK = 287;

assump.cp_gas_J_kgK = 1150;
assump.gamma_gas = 1.333;
assump.R_gas_J_kgK = 287;

assump.Hu_J_kg = 42.7e6;
assump.eta_b = 0.98;
assump.eta_c = 0.86;
assump.eta_tg = 0.88;
assump.eta_pt = 0.89;
assump.eta_mg = 0.99;
assump.eta_mp = 0.99;

assump.sigma_in = 0.99;
assump.sigma_b = 0.95;
assump.P_exh_factor = 1.03;
end

function sweep = sweep_pressure_ratio(req, assump, pi_values)
n = numel(pi_values);
sweep.pi_c = pi_values(:);
sweep.T2_K = zeros(n, 1);
sweep.T4_K = zeros(n, 1);
sweep.T5_K = zeros(n, 1);
sweep.fuel_air_ratio = zeros(n, 1);
sweep.W_air_kgps = zeros(n, 1);
sweep.W_fuel_kgps = zeros(n, 1);
sweep.Wpt_specific_J_kg_air = zeros(n, 1);
sweep.eta_dc = zeros(n, 1);

for k = 1:n
    d = solve_design_point(req, assump, pi_values(k));
    sweep.T2_K(k) = d.state.T2_K;
    sweep.T4_K(k) = d.state.T4_K;
    sweep.T5_K(k) = d.state.T5_K;
    sweep.fuel_air_ratio(k) = d.perf.fuel_air_ratio;
    sweep.W_air_kgps(k) = d.state.W_air_kgps;
    sweep.W_fuel_kgps(k) = d.state.W_fuel_kgps;
    sweep.Wpt_specific_J_kg_air(k) = d.perf.Wpt_specific_J_kg_air;
    sweep.eta_dc(k) = d.perf.eta_dc;
end
end

function design = solve_design_point(req, assump, pi_c)
P1 = assump.sigma_in * req.Pamb_Pa;
T1 = req.Tamb_K;

P2 = P1 * pi_c;
T2s = T1 * pi_c^((assump.gamma_air - 1)/assump.gamma_air);
T2 = T1 + (T2s - T1)/assump.eta_c;

P3 = assump.sigma_b * P2;
T3 = req.T3_design_K;

f = (assump.cp_gas_J_kgK*T3 - assump.cp_air_J_kgK*T2) / ...
    (assump.eta_b*assump.Hu_J_kg - assump.cp_gas_J_kgK*T3);
Wc_specific = assump.cp_air_J_kgK * (T2 - T1);

T4 = T3 - Wc_specific/(assump.eta_mg*(1 + f)*assump.cp_gas_J_kgK);
T4s = T3 - (T3 - T4)/assump.eta_tg;
PR_TG = (T3/T4s)^(assump.gamma_gas/(assump.gamma_gas - 1));
P4 = P3/PR_TG;

P5 = assump.P_exh_factor * req.Pamb_Pa;
PR_PT = P4/P5;
T5s = T4 * (1/PR_PT)^((assump.gamma_gas - 1)/assump.gamma_gas);
T5 = T4 - assump.eta_pt*(T4 - T5s);

Wpt_specific = assump.eta_mp*(1 + f)*assump.cp_gas_J_kgK*(T4 - T5);
W_air = req.P_PT_shaft0_W/Wpt_specific;
W_fuel = f * W_air;
W_gas = W_air + W_fuel;

P_comp = W_air * Wc_specific;
P_TG_gas = W_gas * assump.cp_gas_J_kgK * (T3 - T4);
P_TG_shaft = assump.eta_mg * P_TG_gas;
P_PT_gas = W_gas * assump.cp_gas_J_kgK * (T4 - T5);
P_PT_shaft = assump.eta_mp * P_PT_gas;
Q_fuel = W_fuel * assump.Hu_J_kg;

design.pi_c = pi_c;
design.state = struct( ...
    'P1_Pa', P1, 'T1_K', T1, ...
    'P2_Pa', P2, 'T2s_K', T2s, 'T2_K', T2, ...
    'P3_Pa', P3, 'T3_K', T3, ...
    'P4_Pa', P4, 'T4s_K', T4s, 'T4_K', T4, ...
    'P5_Pa', P5, 'T5s_K', T5s, 'T5_K', T5, ...
    'W_air_kgps', W_air, ...
    'W_fuel_kgps', W_fuel, ...
    'W_gas_kgps', W_gas);
design.perf = struct( ...
    'fuel_air_ratio', f, ...
    'PR_TG', PR_TG, ...
    'PR_PT', PR_PT, ...
    'Wc_specific_J_kg_air', Wc_specific, ...
    'Wpt_specific_J_kg_air', Wpt_specific, ...
    'P_comp_W', P_comp, ...
    'P_TG_gas_W', P_TG_gas, ...
    'P_TG_shaft_W', P_TG_shaft, ...
    'P_PT_gas_W', P_PT_gas, ...
    'P_PT_shaft_W', P_PT_shaft, ...
    'Q_fuel_W', Q_fuel, ...
    'eta_dc', req.P_dc_rated_W/Q_fuel);
end

function mapScale = build_map_scaling(design, req, ~)
% Synthetic public compressor data are used in this example. These values
% document the pressure-axis scaling from the synthetic map to the model
% design point.
local_pi_map_dp = 8.24751;
local_W_map_dp = 0.975281;
local_eta_map_dp = 0.86; % constant fallback for the public synthetic map

mapScale.compressor.primary = 'synthetic_public_compressor_xpi';
mapScale.compressor.fallback = 'constant_eta_public_surrogate';
mapScale.compressor.local_pi_map_dp = local_pi_map_dp;
mapScale.compressor.local_W_map_dp = local_W_map_dp;
mapScale.compressor.local_eta_map_dp = local_eta_map_dp;
mapScale.compressor.local_s_pi = (req.pi_c_nominal - 1)/(local_pi_map_dp - 1);
mapScale.compressor.local_s_W = design.state.W_air_kgps/local_W_map_dp;
mapScale.compressor.local_s_eta = 0.86/local_eta_map_dp;

P3 = design.state.P3_Pa;
P4 = design.state.P4_Pa;
P5 = design.state.P5_Pa;
T3 = design.state.T3_K;
T4 = design.state.T4_K;
Wg = design.state.W_gas_kgps;
mapScale.turbine.primary = 'stodola_flugel';
mapScale.turbine.K_TG = (Wg*sqrt(T3)/P3)/sqrt(1 - (P4/P3)^2);
mapScale.turbine.K_PT = (Wg*sqrt(T4)/P4)/sqrt(1 - (P5/P4)^2);
end

function dyn = define_dynamic_params(design, req, assump)
dyn.J_GG_kgm2 = 20;
dyn.J_PT_kgm2 = 700;

dyn.tau_P3_s = 0.08;
dyn.tau_P4_s = 0.08;
dyn.V3_m3 = dyn.tau_P3_s * assump.R_gas_J_kgK * ...
    design.state.T3_K * design.state.W_gas_kgps / design.state.P3_Pa;
dyn.V4_m3 = dyn.tau_P4_s * assump.R_gas_J_kgK * ...
    design.state.T4_K * design.state.W_gas_kgps / design.state.P4_Pa;

dyn.tau_T3_s = 0.25;
dyn.tau_f_s = 0.15;

dyn.Kp_N = 4.0;
dyn.Ki_N_per_s = 1.5;
dyn.omega_GG_min_radps = 0.3 * pi * req.N_GG0_rpm/30;
dyn.omega_PT_min_radps = 0.3 * pi * req.N_PT0_rpm/30;
end

function init = build_initial_conditions(design, ~, req)
init.omega_GG0_radps = pi * req.N_GG0_rpm/30;
init.omega_PT0_radps = pi * req.N_PT0_rpm/30;
init.N_GG0_rpm = req.N_GG0_rpm;
init.N_PT0_rpm = req.N_PT0_rpm;
init.P3_0_Pa = design.state.P3_Pa;
init.P4_0_Pa = design.state.P4_Pa;
init.T3_0_K = design.state.T3_K;
init.Wf_act0_kgps = design.state.W_fuel_kgps;
init.Pload_shaft0_W = req.P_PT_shaft0_W;
init.Tload0_Nm = req.P_PT_shaft0_W/init.omega_PT0_radps;
init.int_e_N0 = 0;
end

function limits = define_limits(design, req)
limits.T3_design_K = req.T3_design_K;
limits.T3_continuous_limit_K = NaN;
limits.T3_transient_limit_K = NaN;
limits.N_GG_max_rpm = 1.05 * req.N_GG0_rpm;
limits.N_PT_max_rpm = 1.05 * req.N_PT0_rpm;
limits.Wf_min_kgps = 0.30 * design.state.W_fuel_kgps;
limits.Wf_max_normal_kgps = 1.20 * design.state.W_fuel_kgps;
limits.Wf_max_emergency_kgps = 1.30 * design.state.W_fuel_kgps;
limits.Wf_rate_normal_kgps2 = 0.50 * design.state.W_fuel_kgps;
limits.map_valid_required = true;
end

function checks = run_design_checks(design, mapScale, dyn, init, limits, req)
state = design.state;
perf = design.perf;

checks.pressure_order = state.P2_Pa > state.P1_Pa && ...
    state.P3_Pa < state.P2_Pa && state.P4_Pa < state.P3_Pa && ...
    state.P5_Pa < state.P4_Pa;
checks.temperature_order = state.T2_K > state.T1_K && ...
    state.T3_K > state.T4_K && state.T4_K > state.T5_K;
checks.fuel_air_ratio_ok = perf.fuel_air_ratio > 0 && perf.fuel_air_ratio < 0.04;
checks.GG_balance_rel = abs(perf.P_TG_shaft_W - perf.P_comp_W)/perf.P_comp_W;
checks.PT_balance_rel = abs(perf.P_PT_shaft_W - req.P_PT_shaft0_W)/req.P_PT_shaft0_W;
checks.T3_design_match = abs(state.T3_K - limits.T3_design_K) < 1e-12;
checks.K_TG_positive = mapScale.turbine.K_TG > 0;
checks.K_PT_positive = mapScale.turbine.K_PT > 0;
checks.initial_load_torque_positive = init.Tload0_Nm > 0;
checks.V3_positive = dyn.V3_m3 > 0;
checks.V4_positive = dyn.V4_m3 > 0;
checks.model_level = req.model_level;
checks.all_passed = checks.pressure_order && checks.temperature_order && ...
    checks.fuel_air_ratio_ok && checks.GG_balance_rel < 1e-12 && ...
    checks.PT_balance_rel < 1e-12 && checks.T3_design_match && ...
    checks.K_TG_positive && checks.K_PT_positive && ...
    checks.initial_load_torque_positive && checks.V3_positive && checks.V4_positive;
end
