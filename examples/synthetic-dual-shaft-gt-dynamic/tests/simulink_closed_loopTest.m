classdef simulink_closed_loopTest < matlab.unittest.TestCase
    %SIMULINK_CLOSED_LOOPTEST Tests the exploratory Simulink closed loop.

    methods (TestClassSetup)
        function addPackageToPath(testCase)
            testFolder = fileparts(mfilename('fullpath'));
            packageRoot = fileparts(testFolder);
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                fullfile(packageRoot, 'src')));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                fullfile(packageRoot, 'scripts')));
        end
    end

    methods (Test)
        function testRatedLoadRejectionClosedLoop(testCase)
            packageRoot = fileparts(fileparts(mfilename('fullpath')));
            modelPath = fullfile(packageRoot, 'simulink', ...
                'GT_DualShaft_Dynamic_Exploratory.slx');
            if ~isfile(modelPath)
                build_gt_simulink_model();
            end

            GT_SIM = init_gt_simulink_workspace();
            model = 'GT_DualShaft_Dynamic_Exploratory';
            open_system(modelPath);
            simOut = sim(model, 'StopTime', num2str(GT_SIM.stop_time_s));

            plantDiag = simOut.get('plant_diag');
            speedErrorRel = simOut.get('speed_error_rel');
            fuelCmd = simOut.get('fuel_cmd');

            time = plantDiag.Time(:);
            NptRpm = plantDiag.Data(:, 2);
            T3K = plantDiag.Data(:, 5);
            mapValid = plantDiag.Data(:, 10);
            speedErrorRpm = speedErrorRel.Data(:)*GT_SIM.N_PT_ref_rpm;
            afterStep = time >= GT_SIM.load_step_time_s;

            testCase.verifyEqual(get_param(model, 'SolverType'), ...
                'Fixed-step');
            testCase.verifyEqual(get_param(model, 'Solver'), 'ode4');
            testCase.verifyLessThanOrEqual(max(T3K), ...
                GT_SIM.GT.limits.T3_design_K + ...
                GT_SIM.temperature_limit_tol_K);
            testCase.verifyTrue(all(mapValid >= 0.5));
            testCase.verifyLessThanOrEqual( ...
                abs(speedErrorRpm(end)), GT_SIM.final_speed_error_rpm);
            testCase.verifyLessThanOrEqual( ...
                max(abs(speedErrorRpm(afterStep))), ...
                GT_SIM.max_speed_error_rpm);
            testCase.verifyGreaterThanOrEqual(min(fuelCmd.Data(:)), ...
                GT_SIM.Wf_min_kgps - 1e-12);
            testCase.verifyLessThanOrEqual(max(fuelCmd.Data(:)), ...
                GT_SIM.Wf_max_kgps + 1e-12);
            testCase.verifyGreaterThan(max(NptRpm), GT_SIM.N_PT_ref_rpm);
        end
    end
end
