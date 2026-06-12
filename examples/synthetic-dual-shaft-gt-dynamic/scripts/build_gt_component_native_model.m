function modelPath = build_gt_component_native_model()
%BUILD_GT_COMPONENT_NATIVE_MODEL Build a native-block component GT model.
%
% This model intentionally avoids MATLAB Function, Interpreted MATLAB
% Function, and Fcn blocks. Equations are implemented with native Simulink
% arithmetic, lookup-table, logic, and integrator blocks.

thisFile = mfilename('fullpath');
packageRoot = fileparts(fileparts(thisFile));
simRoot = fullfile(packageRoot, 'simulink');
if ~isfolder(simRoot)
    mkdir(simRoot);
end
addpath(fullfile(packageRoot, 'src'));
addpath(fullfile(packageRoot, 'scripts'));
init_gt_simulink_workspace();

model = 'GT_DualShaft_Component_Native';
modelPath = fullfile(simRoot, [model '.slx']);
if bdIsLoaded(model)
    close_system(model, 0);
end
new_system(model);
open_system(model);

set_param(model, ...
    'StopTime', 'GT_SIM.stop_time_s', ...
    'SolverType', 'Fixed-step', ...
    'Solver', 'ode4', ...
    'FixedStep', 'GT_SIM.fixed_step_s', ...
    'RelTol', '1e-6', ...
    'AbsTol', '1e-8', ...
    'InitFcn', 'init_gt_simulink_workspace;');

add_top_level_blocks(model);
add_compressor_subsystem([model '/Compressor']);
add_combustor_subsystem([model '/Combustor']);
add_tg_subsystem([model '/Gas_Generator_Turbine']);
add_pt_subsystem([model '/Power_Turbine']);
add_load_subsystem([model '/DC_Load']);
add_controller_subsystem([model '/PT_Speed_Controller']);
add_rotor_subsystem([model '/GG_Rotor'], 'GG');
add_rotor_subsystem([model '/PT_Rotor'], 'PT');
add_volume_subsystem([model '/P3_Volume'], 'P3');
add_volume_subsystem([model '/P4_Volume'], 'P4');
add_fuel_subsystem([model '/Fuel_Actuator']);
add_diag_subsystem([model '/Diagnostics']);
connect_top_level(model);

save_system(model, modelPath);
end

function add_top_level_blocks(model)
add_block('simulink/Sources/Constant', [model '/N_PT_ref_rpm'], ...
    'Value', 'GT_SIM.N_PT_ref_rpm', 'Position', [40 60 140 90]);
add_block('simulink/Sources/Step', [model '/Pdc_Load_Step'], ...
    'Time', 'GT_SIM.load_step_time_s', ...
    'Before', 'GT_SIM.Pdc0_W', ...
    'After', 'GT_SIM.Pdc_step_W', ...
    'Position', [40 410 140 440]);

add_integrator(model, 'omega_GG', 'GT_SIM.x0(1)', [260 40 300 80]);
add_integrator(model, 'omega_PT', 'GT_SIM.x0(2)', [260 130 300 170]);
add_integrator(model, 'P3', 'GT_SIM.x0(3)', [260 220 300 260]);
add_integrator(model, 'P4', 'GT_SIM.x0(4)', [260 310 300 350]);
add_integrator(model, 'T3', 'GT_SIM.x0(5)', [260 500 300 540]);
add_integrator(model, 'Wf_act', 'GT_SIM.x0(6)', [260 590 300 630]);

add_subsystem(model, 'Compressor', [430 145 570 245]);
add_subsystem(model, 'Combustor', [690 300 830 415]);
add_subsystem(model, 'Gas_Generator_Turbine', [960 255 1135 375]);
add_subsystem(model, 'Power_Turbine', [1250 300 1390 400]);
add_subsystem(model, 'DC_Load', [430 400 570 480]);
add_subsystem(model, 'PT_Speed_Controller', [430 520 600 620]);
add_subsystem(model, 'GG_Rotor', [1250 50 1390 135]);
add_subsystem(model, 'PT_Rotor', [1510 180 1650 265]);
add_subsystem(model, 'P3_Volume', [1250 470 1390 555]);
add_subsystem(model, 'P4_Volume', [1510 470 1650 555]);
add_subsystem(model, 'Fuel_Actuator', [690 560 830 630]);
add_subsystem(model, 'Diagnostics', [1510 590 1680 720]);

add_block('simulink/Sinks/To Workspace', [model '/component_diag_log'], ...
    'VariableName', 'component_diag', 'SaveFormat', 'Timeseries', ...
    'Position', [1750 630 1880 660]);
end

function add_integrator(model, name, ic, pos)
add_block('simulink/Continuous/Integrator', [model '/' name], ...
    'InitialCondition', ic, 'Position', pos);
end

function add_subsystem(model, name, pos)
path = [model '/' name];
add_block('simulink/Ports & Subsystems/Subsystem', path, 'Position', pos);
try
    delete_line(path, 'In1/1', 'Out1/1');
catch
end
try
    delete_block([path '/In1']);
    delete_block([path '/Out1']);
catch
end
end

function add_compressor_subsystem(path)
add_in(path, 'omega_GG', 1, [25 35 55 49]);
add_in(path, 'P3', 2, [25 95 55 109]);
add_out(path, 'P2', 1, [760 25 790 39]);
add_out(path, 'T2', 2, [760 70 790 84]);
add_out(path, 'W_air', 3, [760 115 790 129]);
add_out(path, 'P_comp', 4, [760 160 790 174]);
add_out(path, 'pi_c', 5, [760 205 790 219]);
add_out(path, 'map_valid', 6, [760 250 790 264]);

add_gain(path, 'P2_from_P3', '1/GT_SIM.GT.assump.sigma_b', [90 85 180 120]);
add_product(path, 'pi_raw_div', '*/', [220 85 250 120]);
add_const(path, 'P1_const', 'GT_SIM.comp.P1_Pa', [90 140 180 170]);
add_sat(path, 'pi_floor', 'GT_SIM.comp.compressor.pi_floor', 'inf', ...
    [285 85 350 120]);
add_sum(path, 'pi_minus_1', '+-', [385 85 410 120]);
add_const(path, 'one_a', '1', [340 145 370 175]);
add_gain(path, 'pi_scale_inv', '1/GT_SIM.comp.compressor.local_s_pi', ...
    [440 85 530 120]);
add_sum(path, 'pi_map_plus_1', '++', [560 85 585 120]);
add_const(path, 'one_b', '1', [520 145 550 175]);
add_gain(path, 'N_rel_gain', '1/GT_SIM.comp.omega_GG0_radps', ...
    [90 25 185 60]);
add_sat(path, 'pi_map_sat', 'GT_SIM.comp.compressor.pi_min', ...
    'GT_SIM.comp.compressor.pi_max', [620 70 690 105]);
add_sat(path, 'N_rel_sat', 'GT_SIM.comp.compressor.N_min', ...
    'GT_SIM.comp.compressor.N_max', [220 25 290 60]);
add_block('simulink/Lookup Tables/2-D Lookup Table', ...
    [path '/Compressor_Map'], ...
    'BreakpointsForDimension1', 'GT_SIM.comp.compressor.pi_bp', ...
    'BreakpointsForDimension2', 'GT_SIM.comp.compressor.N_bp', ...
    'Table', 'GT_SIM.comp.compressor.W_map_table', ...
    'Position', [620 125 720 185]);
add_block('simulink/Lookup Tables/2-D Lookup Table', ...
    [path '/Map_Valid_Table'], ...
    'BreakpointsForDimension1', 'GT_SIM.comp.compressor.pi_bp', ...
    'BreakpointsForDimension2', 'GT_SIM.comp.compressor.N_bp', ...
    'Table', 'GT_SIM.comp.compressor.valid_table', ...
    'Position', [620 325 720 385]);
add_gain(path, 'W_scale', 'GT_SIM.comp.compressor.local_s_W', ...
    [745 125 830 160]);
add_sat(path, 'W_nonnegative', '0', 'inf', [855 125 930 160]);

add_math(path, 'log_pi', 'log', [385 200 430 235]);
add_gain(path, 'air_exp_gain', 'GT_SIM.comp.air_exp', [460 200 535 235]);
add_math(path, 'exp_pi', 'exp', [565 200 610 235]);
add_gain(path, 'T2s_gain', 'GT_SIM.comp.T1_K', [635 200 720 235]);
add_sum(path, 'T2s_minus_T1', '+-', [745 200 770 235]);
add_const(path, 'T1_const_a', 'GT_SIM.comp.T1_K', [700 250 730 280]);
add_gain(path, 'eta_c_inv', '1/GT_SIM.comp.compressor.eta_c', ...
    [795 200 870 235]);
add_sum(path, 'T2_plus_T1', '++', [895 200 920 235]);
add_const(path, 'T1_const_b', 'GT_SIM.comp.T1_K', [850 250 880 280]);

add_sum(path, 'T2_minus_T1', '+-', [960 200 985 235]);
add_const(path, 'T1_const_c', 'GT_SIM.comp.T1_K', [920 250 950 280]);
add_product(path, 'W_times_dT', '**', [1015 150 1045 190]);
add_gain(path, 'cp_air_gain', 'GT_SIM.GT.assump.cp_air_J_kgK', ...
    [1075 150 1165 185]);

add_relop(path, 'pi_ge_min', '>=', [620 230 665 260]);
add_relop(path, 'pi_le_max', '<=', [620 275 665 305]);
add_relop(path, 'N_ge_min', '>=', [700 230 745 260]);
add_relop(path, 'N_le_max', '<=', [700 275 745 305]);
add_relop(path, 'valid_ge_half', '>=', [760 340 805 370]);
add_const(path, 'valid_half_const', '0.5', [705 395 750 425]);
add_logic(path, 'map_valid_and', 'AND', '5', [850 250 900 320]);
add_dtc(path, 'map_valid_double', 'double', [875 260 945 295]);
add_const(path, 'pi_min_const', 'GT_SIM.comp.compressor.pi_min', ...
    [555 245 600 275]);
add_const(path, 'pi_max_const', 'GT_SIM.comp.compressor.pi_max', ...
    [555 290 600 320]);
add_const(path, 'N_min_const', 'GT_SIM.comp.compressor.N_min', ...
    [635 245 680 275]);
add_const(path, 'N_max_const', 'GT_SIM.comp.compressor.N_max', ...
    [635 290 680 320]);

line(path, 'P3/1', 'P2_from_P3/1');
line(path, 'P2_from_P3/1', 'P2/1');
line(path, 'P2_from_P3/1', 'pi_raw_div/1');
line(path, 'P1_const/1', 'pi_raw_div/2');
line(path, 'pi_raw_div/1', 'pi_floor/1');
line(path, 'pi_floor/1', 'pi_minus_1/1');
line(path, 'one_a/1', 'pi_minus_1/2');
line(path, 'pi_minus_1/1', 'pi_scale_inv/1');
line(path, 'pi_scale_inv/1', 'pi_map_plus_1/1');
line(path, 'one_b/1', 'pi_map_plus_1/2');
line(path, 'pi_map_plus_1/1', 'pi_map_sat/1');
line(path, 'omega_GG/1', 'N_rel_gain/1');
line(path, 'N_rel_gain/1', 'N_rel_sat/1');
line(path, 'pi_map_sat/1', 'Compressor_Map/1');
line(path, 'N_rel_sat/1', 'Compressor_Map/2');
line(path, 'pi_map_sat/1', 'Map_Valid_Table/1');
line(path, 'N_rel_sat/1', 'Map_Valid_Table/2');
line(path, 'Compressor_Map/1', 'W_scale/1');
line(path, 'W_scale/1', 'W_nonnegative/1');
line(path, 'W_nonnegative/1', 'W_air/1');
line(path, 'pi_floor/1', 'pi_c/1');
line(path, 'pi_floor/1', 'log_pi/1');
line(path, 'log_pi/1', 'air_exp_gain/1');
line(path, 'air_exp_gain/1', 'exp_pi/1');
line(path, 'exp_pi/1', 'T2s_gain/1');
line(path, 'T2s_gain/1', 'T2s_minus_T1/1');
line(path, 'T1_const_a/1', 'T2s_minus_T1/2');
line(path, 'T2s_minus_T1/1', 'eta_c_inv/1');
line(path, 'eta_c_inv/1', 'T2_plus_T1/1');
line(path, 'T1_const_b/1', 'T2_plus_T1/2');
line(path, 'T2_plus_T1/1', 'T2/1');
line(path, 'T2_plus_T1/1', 'T2_minus_T1/1');
line(path, 'T1_const_c/1', 'T2_minus_T1/2');
line(path, 'W_nonnegative/1', 'W_times_dT/1');
line(path, 'T2_minus_T1/1', 'W_times_dT/2');
line(path, 'W_times_dT/1', 'cp_air_gain/1');
line(path, 'cp_air_gain/1', 'P_comp/1');
line(path, 'pi_map_plus_1/1', 'pi_ge_min/1');
line(path, 'pi_min_const/1', 'pi_ge_min/2');
line(path, 'pi_map_plus_1/1', 'pi_le_max/1');
line(path, 'pi_max_const/1', 'pi_le_max/2');
line(path, 'N_rel_gain/1', 'N_ge_min/1');
line(path, 'N_min_const/1', 'N_ge_min/2');
line(path, 'N_rel_gain/1', 'N_le_max/1');
line(path, 'N_max_const/1', 'N_le_max/2');
line(path, 'pi_ge_min/1', 'map_valid_and/1');
line(path, 'pi_le_max/1', 'map_valid_and/2');
line(path, 'N_ge_min/1', 'map_valid_and/3');
line(path, 'N_le_max/1', 'map_valid_and/4');
line(path, 'Map_Valid_Table/1', 'valid_ge_half/1');
line(path, 'valid_half_const/1', 'valid_ge_half/2');
line(path, 'valid_ge_half/1', 'map_valid_and/5');
line(path, 'map_valid_and/1', 'map_valid_double/1');
line(path, 'map_valid_double/1', 'map_valid/1');
end

function add_combustor_subsystem(path)
add_in(path, 'W_air', 1, [25 35 55 49]);
add_in(path, 'T2', 2, [25 90 55 104]);
add_in(path, 'T3', 3, [25 145 55 159]);
add_in(path, 'Wf_act', 4, [25 200 55 214]);
add_out(path, 'W_gas', 1, [735 35 765 49]);
add_out(path, 'T3_eq', 2, [735 90 765 104]);
add_out(path, 'T3_dot', 3, [735 145 765 159]);
add_out(path, 'fuel_air_ratio', 4, [735 200 765 214]);

add_sat(path, 'Wf_nonnegative', '0', 'inf', [90 190 165 225]);
add_sum(path, 'Wgas_sum', '++', [215 55 240 95]);
add_product(path, 'air_heat_product', '**', [215 115 245 155]);
add_gain(path, 'cp_air_gain', 'GT_SIM.GT.assump.cp_air_J_kgK', ...
    [275 115 365 150]);
add_product(path, 'fuel_heat_product', '**', [215 245 245 285]);
add_const(path, 'Hu_eta_const', ...
    'GT_SIM.GT.assump.eta_b*GT_SIM.GT.assump.Hu_J_kg', ...
    [90 260 190 290]);
add_sum(path, 'energy_sum', '++', [420 160 445 205]);
add_const(path, 'cp_gas_const', 'GT_SIM.GT.assump.cp_gas_J_kgK', ...
    [275 40 365 75]);
add_product(path, 'denominator', '**', [420 55 450 95]);
add_product(path, 'T3_eq_divide', '*/', [500 120 530 165]);
add_sum(path, 'T3_error', '+-', [575 135 600 175]);
add_gain(path, 'T3_tau_inv', '1/GT_SIM.GT.dyn.tau_T3_s', ...
    [630 145 705 180]);
add_product(path, 'far_divide', '*/', [500 205 530 245]);

line(path, 'Wf_act/1', 'Wf_nonnegative/1');
line(path, 'W_air/1', 'Wgas_sum/1');
line(path, 'Wf_nonnegative/1', 'Wgas_sum/2');
line(path, 'Wgas_sum/1', 'W_gas/1');
line(path, 'W_air/1', 'air_heat_product/1');
line(path, 'T2/1', 'air_heat_product/2');
line(path, 'air_heat_product/1', 'cp_air_gain/1');
line(path, 'Wf_nonnegative/1', 'fuel_heat_product/1');
line(path, 'Hu_eta_const/1', 'fuel_heat_product/2');
line(path, 'cp_air_gain/1', 'energy_sum/1');
line(path, 'fuel_heat_product/1', 'energy_sum/2');
line(path, 'Wgas_sum/1', 'denominator/1');
line(path, 'cp_gas_const/1', 'denominator/2');
line(path, 'energy_sum/1', 'T3_eq_divide/1');
line(path, 'denominator/1', 'T3_eq_divide/2');
line(path, 'T3_eq_divide/1', 'T3_eq/1');
line(path, 'T3_eq_divide/1', 'T3_error/1');
line(path, 'T3/1', 'T3_error/2');
line(path, 'T3_error/1', 'T3_tau_inv/1');
line(path, 'T3_tau_inv/1', 'T3_dot/1');
line(path, 'Wf_nonnegative/1', 'far_divide/1');
line(path, 'W_air/1', 'far_divide/2');
line(path, 'far_divide/1', 'fuel_air_ratio/1');
end

function add_tg_subsystem(path)
add_turbine_core(path, 'TG', 'GT_SIM.GT.mapScale.turbine.K_TG', ...
    'GT_SIM.GT.assump.eta_tg', 'GT_SIM.GT.assump.eta_mg');
end

function add_pt_subsystem(path)
add_turbine_core(path, 'PT', 'GT_SIM.GT.mapScale.turbine.K_PT', ...
    'GT_SIM.GT.assump.eta_pt', 'GT_SIM.GT.assump.eta_mp');
end

function add_turbine_core(path, mode, Kexpr, etaExpr, mechExpr)
if strcmp(mode, 'TG')
    add_in(path, 'Pin', 1, [25 35 55 49]);
    add_in(path, 'Pout', 2, [25 90 55 104]);
    add_in(path, 'Tin', 3, [25 145 55 159]);
else
    add_in(path, 'Pin', 1, [25 35 55 49]);
    add_in(path, 'Tin', 2, [25 90 55 104]);
    add_const(path, 'Pout_const', 'GT_SIM.comp.P5_Pa', [25 145 115 175]);
end
add_out(path, 'W_turbine', 1, [850 35 880 49]);
add_out(path, 'Tout', 2, [850 90 880 104]);
add_out(path, 'P_shaft', 3, [850 145 880 159]);
add_out(path, 'PR', 4, [850 200 880 214]);
add_out(path, 'map_valid', 5, [850 255 880 269]);

add_product(path, 'PR_divide', '*/', [145 45 175 85]);
add_sat(path, 'PR_floor', '1.001', 'inf', [205 45 270 80]);
add_product(path, 'Pout_over_Pin', '*/', [145 125 175 165]);
add_product(path, 'ratio_square', '**', [205 125 235 165]);
add_sum(path, 'one_minus_ratio_sq', '+-', [270 125 295 165]);
add_const(path, 'one_const', '1', [225 185 255 215]);
add_sat(path, 'flow_term_nonnegative', '0', 'inf', [325 125 390 160]);
add_math(path, 'sqrt_term', 'sqrt', [420 125 465 160]);
add_math(path, 'sqrt_Tin', 'sqrt', [145 225 190 260]);
add_product(path, 'Pin_over_sqrtT', '*/', [230 205 260 245]);
add_gain(path, 'K_gain', Kexpr, [300 205 385 240]);
add_product(path, 'flow_product', '**', [500 155 530 195]);

add_math(path, 'log_PR', 'log', [300 45 345 80]);
add_gain(path, 'neg_gas_exp', '-GT_SIM.comp.gas_exp', [375 45 455 80]);
add_math(path, 'exp_drop', 'exp', [485 45 530 80]);
add_product(path, 'Tis_product', '**', [565 65 595 105]);
add_sum(path, 'Tin_minus_Tis', '+-', [625 90 650 130]);
add_gain(path, 'eta_gain', etaExpr, [680 90 755 125]);
add_sum(path, 'Tout_sum', '+-', [785 90 810 130]);

add_sum(path, 'Tin_minus_Tout', '+-', [565 250 590 290]);
add_product(path, 'flow_times_dT', '**', [625 235 655 275]);
add_gain(path, 'cp_gas_gain', 'GT_SIM.GT.assump.cp_gas_J_kgK', ...
    [685 235 760 270]);
add_gain(path, 'mech_gain', mechExpr, [785 235 845 270]);
add_relop(path, 'PR_valid_gt_one', '>', [625 315 670 345]);
add_const(path, 'one_valid_const', '1', [560 330 605 360]);

if strcmp(mode, 'TG')
    line(path, 'Pout/1', 'PR_divide/2');
    line(path, 'Pout/1', 'Pout_over_Pin/1');
else
    line(path, 'Pout_const/1', 'PR_divide/2');
    line(path, 'Pout_const/1', 'Pout_over_Pin/1');
end
line(path, 'Pin/1', 'PR_divide/1');
line(path, 'Pin/1', 'Pout_over_Pin/2');
line(path, 'PR_divide/1', 'PR_floor/1');
line(path, 'PR_floor/1', 'PR/1');
line(path, 'Pout_over_Pin/1', 'ratio_square/1');
line(path, 'Pout_over_Pin/1', 'ratio_square/2');
line(path, 'one_const/1', 'one_minus_ratio_sq/1');
line(path, 'ratio_square/1', 'one_minus_ratio_sq/2');
line(path, 'one_minus_ratio_sq/1', 'flow_term_nonnegative/1');
line(path, 'flow_term_nonnegative/1', 'sqrt_term/1');
line(path, 'Tin/1', 'sqrt_Tin/1');
line(path, 'Pin/1', 'Pin_over_sqrtT/1');
line(path, 'sqrt_Tin/1', 'Pin_over_sqrtT/2');
line(path, 'Pin_over_sqrtT/1', 'K_gain/1');
line(path, 'K_gain/1', 'flow_product/1');
line(path, 'sqrt_term/1', 'flow_product/2');
line(path, 'flow_product/1', 'W_turbine/1');
line(path, 'PR_floor/1', 'log_PR/1');
line(path, 'log_PR/1', 'neg_gas_exp/1');
line(path, 'neg_gas_exp/1', 'exp_drop/1');
line(path, 'Tin/1', 'Tis_product/1');
line(path, 'exp_drop/1', 'Tis_product/2');
line(path, 'Tin/1', 'Tin_minus_Tis/1');
line(path, 'Tis_product/1', 'Tin_minus_Tis/2');
line(path, 'Tin_minus_Tis/1', 'eta_gain/1');
line(path, 'Tin/1', 'Tout_sum/1');
line(path, 'eta_gain/1', 'Tout_sum/2');
line(path, 'Tout_sum/1', 'Tout/1');
line(path, 'Tin/1', 'Tin_minus_Tout/1');
line(path, 'Tout_sum/1', 'Tin_minus_Tout/2');
line(path, 'flow_product/1', 'flow_times_dT/1');
line(path, 'Tin_minus_Tout/1', 'flow_times_dT/2');
line(path, 'flow_times_dT/1', 'cp_gas_gain/1');
line(path, 'cp_gas_gain/1', 'mech_gain/1');
line(path, 'mech_gain/1', 'P_shaft/1');
line(path, 'PR_divide/1', 'PR_valid_gt_one/1');
line(path, 'one_valid_const/1', 'PR_valid_gt_one/2');
line(path, 'PR_valid_gt_one/1', 'map_valid/1');
end

function add_load_subsystem(path)
add_in(path, 'omega_PT', 1, [25 35 55 49]);
add_in(path, 'Pdc_load', 2, [25 95 55 109]);
add_out(path, 'Pload_shaft', 1, [520 35 550 49]);
add_out(path, 'Tload', 2, [520 95 550 109]);
add_sat(path, 'omega_safe', 'GT_SIM.GT.dyn.omega_PT_min_radps', ...
    'inf', [100 25 175 60]);
add_gain(path, 'eta_chain_inv', '1/GT_SIM.comp.eta_chain', ...
    [105 95 195 130]);
add_product(path, 'torque_divide', '*/', [255 70 285 110]);
line(path, 'omega_PT/1', 'omega_safe/1');
line(path, 'Pdc_load/1', 'eta_chain_inv/1');
line(path, 'eta_chain_inv/1', 'Pload_shaft/1');
line(path, 'eta_chain_inv/1', 'torque_divide/1');
line(path, 'omega_safe/1', 'torque_divide/2');
line(path, 'torque_divide/1', 'Tload/1');
end

function add_controller_subsystem(path)
add_in(path, 'omega_PT', 1, [25 35 55 49]);
add_in(path, 'N_ref_rpm', 2, [25 95 55 109]);
add_out(path, 'Wf_cmd', 1, [700 70 730 84]);
add_gain(path, 'radps_to_rpm', '30/pi', [95 25 170 60]);
add_sum(path, 'speed_error_rpm', '+-', [220 50 245 90]);
add_gain(path, 'normalize_error', '1/GT_SIM.N_PT_ref_rpm', ...
    [280 50 375 85]);
add_gain(path, 'Kp', 'GT_SIM.Kp_fuel', [410 20 485 55]);
add_block('simulink/Continuous/Integrator', [path '/Error_Integrator'], ...
    'InitialCondition', 'GT_SIM.int_e0', 'Position', [410 105 450 145]);
add_gain(path, 'Ki', 'GT_SIM.Ki_fuel', [485 110 560 145]);
add_const(path, 'base_factor', '1', [410 180 450 210]);
add_sum(path, 'fuel_factor_sum', '+++', [590 70 615 135]);
add_gain(path, 'fuel_scale', 'GT_SIM.Wf0_kgps', [640 80 725 115]);
add_sat(path, 'fuel_saturation', 'GT_SIM.Wf_min_kgps', ...
    'GT_SIM.Wf_max_kgps', [755 80 835 115]);
line(path, 'omega_PT/1', 'radps_to_rpm/1');
line(path, 'N_ref_rpm/1', 'speed_error_rpm/1');
line(path, 'radps_to_rpm/1', 'speed_error_rpm/2');
line(path, 'speed_error_rpm/1', 'normalize_error/1');
line(path, 'normalize_error/1', 'Kp/1');
line(path, 'normalize_error/1', 'Error_Integrator/1');
line(path, 'Error_Integrator/1', 'Ki/1');
line(path, 'Kp/1', 'fuel_factor_sum/1');
line(path, 'Ki/1', 'fuel_factor_sum/2');
line(path, 'base_factor/1', 'fuel_factor_sum/3');
line(path, 'fuel_factor_sum/1', 'fuel_scale/1');
line(path, 'fuel_scale/1', 'fuel_saturation/1');
line(path, 'fuel_saturation/1', 'Wf_cmd/1');
end

function add_rotor_subsystem(path, mode)
if strcmp(mode, 'GG')
    inertiaExpr = 'GT_SIM.GT.dyn.J_GG_kgm2';
    omegaMinExpr = 'GT_SIM.GT.dyn.omega_GG_min_radps';
else
    inertiaExpr = 'GT_SIM.GT.dyn.J_PT_kgm2';
    omegaMinExpr = 'GT_SIM.GT.dyn.omega_PT_min_radps';
end
add_in(path, 'P_in', 1, [25 35 55 49]);
add_in(path, 'P_out', 2, [25 95 55 109]);
add_in(path, 'omega', 3, [25 155 55 169]);
add_out(path, 'omega_dot', 1, [485 80 515 94]);
add_sum(path, 'power_balance', '+-', [95 55 120 95]);
add_sat(path, 'omega_safe', omegaMinExpr, 'inf', [95 145 170 180]);
add_gain(path, 'inertia_gain', inertiaExpr, [205 145 285 180]);
add_product(path, 'divide_by_Jomega', '*/', [330 85 360 125]);
line(path, 'P_in/1', 'power_balance/1');
line(path, 'P_out/1', 'power_balance/2');
line(path, 'omega/1', 'omega_safe/1');
line(path, 'omega_safe/1', 'inertia_gain/1');
line(path, 'power_balance/1', 'divide_by_Jomega/1');
line(path, 'inertia_gain/1', 'divide_by_Jomega/2');
line(path, 'divide_by_Jomega/1', 'omega_dot/1');
end

function add_volume_subsystem(path, mode)
if strcmp(mode, 'P3')
    tempGain = 'GT_SIM.GT.assump.R_gas_J_kgK/GT_SIM.GT.dyn.V3_m3';
else
    tempGain = 'GT_SIM.GT.assump.R_gas_J_kgK/GT_SIM.GT.dyn.V4_m3';
end
add_in(path, 'W_in', 1, [25 35 55 49]);
add_in(path, 'W_out', 2, [25 95 55 109]);
add_in(path, 'T_rep', 3, [25 155 55 169]);
add_out(path, 'P_dot', 1, [500 80 530 94]);
add_sum(path, 'flow_balance', '+-', [100 55 125 95]);
add_product(path, 'T_times_flow', '**', [185 85 215 125]);
add_gain(path, 'RT_over_V', tempGain, [255 90 355 125]);
line(path, 'W_in/1', 'flow_balance/1');
line(path, 'W_out/1', 'flow_balance/2');
line(path, 'T_rep/1', 'T_times_flow/1');
line(path, 'flow_balance/1', 'T_times_flow/2');
line(path, 'T_times_flow/1', 'RT_over_V/1');
line(path, 'RT_over_V/1', 'P_dot/1');
end

function add_fuel_subsystem(path)
add_in(path, 'Wf_cmd', 1, [25 35 55 49]);
add_in(path, 'Wf_act', 2, [25 95 55 109]);
add_out(path, 'Wf_dot', 1, [390 65 420 79]);
add_sum(path, 'fuel_error', '+-', [95 55 120 95]);
add_gain(path, 'tau_f_inv', '1/GT_SIM.GT.dyn.tau_f_s', ...
    [170 60 255 95]);
line(path, 'Wf_cmd/1', 'fuel_error/1');
line(path, 'Wf_act/1', 'fuel_error/2');
line(path, 'fuel_error/1', 'tau_f_inv/1');
line(path, 'tau_f_inv/1', 'Wf_dot/1');
end

function add_diag_subsystem(path)
add_in(path, 'omega_GG', 1, [25 25 55 39]);
add_in(path, 'omega_PT', 2, [25 65 55 79]);
add_in(path, 'P3', 3, [25 105 55 119]);
add_in(path, 'P4', 4, [25 145 55 159]);
add_in(path, 'T3', 5, [25 185 55 199]);
add_in(path, 'Wf_act', 6, [25 225 55 239]);
add_in(path, 'Wf_cmd', 7, [25 265 55 279]);
add_in(path, 'Pdc_load', 8, [25 305 55 319]);
add_in(path, 'P_PT', 9, [25 345 55 359]);
add_in(path, 'map_valid', 10, [25 385 55 399]);
add_out(path, 'diag', 1, [575 205 605 219]);
add_gain(path, 'GG_rpm', '30/pi', [105 20 175 50]);
add_gain(path, 'PT_rpm', '30/pi', [105 60 175 90]);
add_gain(path, 'P3_MPa', '1e-6', [105 100 175 130]);
add_gain(path, 'P4_MPa', '1e-6', [105 140 175 170]);
add_gain(path, 'PPT_MW', '1e-6', [105 340 175 370]);
add_dtc(path, 'map_valid_double', 'double', [105 380 175 410]);
add_block('simulink/Signal Routing/Mux', [path '/diag_mux'], ...
    'Inputs', '10', 'Position', [460 145 490 320]);
line(path, 'omega_GG/1', 'GG_rpm/1');
line(path, 'GG_rpm/1', 'diag_mux/1');
line(path, 'omega_PT/1', 'PT_rpm/1');
line(path, 'PT_rpm/1', 'diag_mux/2');
line(path, 'P3/1', 'P3_MPa/1');
line(path, 'P3_MPa/1', 'diag_mux/3');
line(path, 'P4/1', 'P4_MPa/1');
line(path, 'P4_MPa/1', 'diag_mux/4');
line(path, 'T3/1', 'diag_mux/5');
line(path, 'Wf_act/1', 'diag_mux/6');
line(path, 'Wf_cmd/1', 'diag_mux/7');
line(path, 'Pdc_load/1', 'diag_mux/8');
line(path, 'P_PT/1', 'PPT_MW/1');
line(path, 'PPT_MW/1', 'diag_mux/9');
line(path, 'map_valid/1', 'map_valid_double/1');
line(path, 'map_valid_double/1', 'diag_mux/10');
line(path, 'diag_mux/1', 'diag/1');
end

function connect_top_level(model)
line(model, 'Pdc_Load_Step/1', 'DC_Load/2');
line(model, 'N_PT_ref_rpm/1', 'PT_Speed_Controller/2');

line(model, 'omega_GG/1', 'Compressor/1');
line(model, 'P3/1', 'Compressor/2');
line(model, 'Compressor/3', 'Combustor/1');
line(model, 'Compressor/2', 'Combustor/2');
line(model, 'T3/1', 'Combustor/3');
line(model, 'Wf_act/1', 'Combustor/4');

line(model, 'P3/1', 'Gas_Generator_Turbine/1');
line(model, 'P4/1', 'Gas_Generator_Turbine/2');
line(model, 'T3/1', 'Gas_Generator_Turbine/3');
line(model, 'P4/1', 'Power_Turbine/1');
line(model, 'Gas_Generator_Turbine/2', 'Power_Turbine/2');

line(model, 'omega_PT/1', 'DC_Load/1');
line(model, 'omega_PT/1', 'PT_Speed_Controller/1');
line(model, 'PT_Speed_Controller/1', 'Fuel_Actuator/1');
line(model, 'Wf_act/1', 'Fuel_Actuator/2');

line(model, 'Gas_Generator_Turbine/3', 'GG_Rotor/1');
line(model, 'Compressor/4', 'GG_Rotor/2');
line(model, 'omega_GG/1', 'GG_Rotor/3');
line(model, 'Power_Turbine/3', 'PT_Rotor/1');
line(model, 'DC_Load/1', 'PT_Rotor/2');
line(model, 'omega_PT/1', 'PT_Rotor/3');

line(model, 'Combustor/1', 'P3_Volume/1');
line(model, 'Gas_Generator_Turbine/1', 'P3_Volume/2');
line(model, 'T3/1', 'P3_Volume/3');
line(model, 'Gas_Generator_Turbine/1', 'P4_Volume/1');
line(model, 'Power_Turbine/1', 'P4_Volume/2');
line(model, 'Gas_Generator_Turbine/2', 'P4_Volume/3');

line(model, 'GG_Rotor/1', 'omega_GG/1');
line(model, 'PT_Rotor/1', 'omega_PT/1');
line(model, 'P3_Volume/1', 'P3/1');
line(model, 'P4_Volume/1', 'P4/1');
line(model, 'Combustor/3', 'T3/1');
line(model, 'Fuel_Actuator/1', 'Wf_act/1');

line(model, 'omega_GG/1', 'Diagnostics/1');
line(model, 'omega_PT/1', 'Diagnostics/2');
line(model, 'P3/1', 'Diagnostics/3');
line(model, 'P4/1', 'Diagnostics/4');
line(model, 'T3/1', 'Diagnostics/5');
line(model, 'Wf_act/1', 'Diagnostics/6');
line(model, 'PT_Speed_Controller/1', 'Diagnostics/7');
line(model, 'Pdc_Load_Step/1', 'Diagnostics/8');
line(model, 'Power_Turbine/3', 'Diagnostics/9');
line(model, 'Compressor/6', 'Diagnostics/10');
line(model, 'Diagnostics/1', 'component_diag_log/1');
end

function add_in(path, name, port, pos)
add_block('simulink/Sources/In1', [path '/' name], 'Port', num2str(port), ...
    'Position', pos);
end

function add_out(path, name, port, pos)
add_block('simulink/Sinks/Out1', [path '/' name], 'Port', num2str(port), ...
    'Position', pos);
end

function add_const(path, name, value, pos)
add_block('simulink/Sources/Constant', [path '/' name], 'Value', value, ...
    'Position', pos);
end

function add_gain(path, name, gain, pos)
add_block('simulink/Math Operations/Gain', [path '/' name], ...
    'Gain', gain, 'Position', pos);
end

function add_sum(path, name, inputs, pos)
add_block('simulink/Math Operations/Sum', [path '/' name], ...
    'Inputs', inputs, 'Position', pos);
end

function add_product(path, name, inputs, pos)
add_block('simulink/Math Operations/Product', [path '/' name], ...
    'Inputs', inputs, 'Position', pos);
end

function add_sat(path, name, lower, upper, pos)
add_block('simulink/Discontinuities/Saturation', [path '/' name], ...
    'LowerLimit', lower, 'UpperLimit', upper, 'Position', pos);
end

function add_math(path, name, fun, pos)
add_block('simulink/Math Operations/Math Function', [path '/' name], ...
    'Operator', fun, 'Position', pos);
end

function add_relop(path, name, op, pos)
add_block('simulink/Logic and Bit Operations/Relational Operator', ...
    [path '/' name], 'Operator', op, 'Position', pos);
end

function add_logic(path, name, op, inputs, pos)
add_block('simulink/Logic and Bit Operations/Logical Operator', ...
    [path '/' name], 'Operator', op, 'Inputs', inputs, 'Position', pos);
end

function add_dtc(path, name, outType, pos)
add_block('simulink/Signal Attributes/Data Type Conversion', ...
    [path '/' name], 'OutDataTypeStr', outType, 'Position', pos);
end

function line(path, src, dst)
add_line(path, src, dst, 'autorouting', 'on');
end
