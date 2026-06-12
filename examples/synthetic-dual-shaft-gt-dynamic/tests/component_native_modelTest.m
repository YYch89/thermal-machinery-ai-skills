classdef component_native_modelTest < matlab.unittest.TestCase
    %COMPONENT_NATIVE_MODELTEST Tests native-block component Simulink model.

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
        function testNoFunctionLikeBlocks(testCase)
            model = 'GT_DualShaft_Component_Native';
            modelPath = ensureModelBuilt(model);
            open_system(modelPath);
            blocks = find_system(model, 'LookUnderMasks', 'all', ...
                'FollowLinks', 'on', 'Type', 'Block');

            forbidden = false(size(blocks));
            for k = 1:numel(blocks)
                blockType = get_param(blocks{k}, 'BlockType');
                name = get_param(blocks{k}, 'Name');
                maskType = get_param(blocks{k}, 'MaskType');
                forbidden(k) = any(strcmp(blockType, ...
                    {'MATLABFcn', 'Fcn'})) || ...
                    contains(name, 'MATLAB Function') || ...
                    contains(name, 'Interpreted MATLAB') || ...
                    contains(maskType, 'MATLAB Function') || ...
                    contains(maskType, 'Interpreted');
            end

            testCase.verifyFalse(any(forbidden));
        end

        function testInitialConditionHoldsBeforeStep(testCase)
            GT_SIM = init_gt_simulink_workspace();
            model = 'GT_DualShaft_Component_Native';
            modelPath = ensureModelBuilt(model);
            open_system(modelPath);

            simOut = sim(model, 'StopTime', '0.05');
            diag = simOut.get('component_diag');

            testCase.verifyEqual(diag.Data(1, 1), GT_SIM.GT.init.N_GG0_rpm, ...
                'AbsTol', 1e-9);
            testCase.verifyEqual(diag.Data(1, 2), GT_SIM.GT.init.N_PT0_rpm, ...
                'AbsTol', 1e-9);
            testCase.verifyEqual(diag.Data(end, 2), ...
                GT_SIM.GT.init.N_PT0_rpm, ...
                'AbsTol', GT_SIM.initial_speed_tol_rpm);
            testCase.verifyEqual(diag.Data(end, 5), ...
                GT_SIM.GT.design.state.T3_K, ...
                'AbsTol', GT_SIM.initial_temperature_tol_K);
            testCase.verifyTrue(all(diag.Data(:, 10) >= 0.5));
        end

        function testNativeClosedLoopLoadRejection(testCase)
            GT_SIM = init_gt_simulink_workspace();
            model = 'GT_DualShaft_Component_Native';
            modelPath = ensureModelBuilt(model);
            open_system(modelPath);

            simOut = sim(model, 'StopTime', ...
                num2str(GT_SIM.component_long_stop_time_s));
            diag = simOut.get('component_diag');

            time = diag.Time(:);
            NggRpm = diag.Data(:, 1);
            NptRpm = diag.Data(:, 2);
            T3K = diag.Data(:, 5);
            WfCmd = diag.Data(:, 7);
            mapValid = diag.Data(:, 10);
            speedErrorRpm = GT_SIM.N_PT_ref_rpm - NptRpm;
            afterStep = time >= GT_SIM.load_step_time_s;
            last10 = time >= GT_SIM.component_long_stop_time_s - 10;

            testCase.verifyEqual(get_param(model, 'SolverType'), ...
                'Fixed-step');
            testCase.verifyEqual(get_param(model, 'Solver'), 'ode4');
            testCase.verifyTrue(all(mapValid >= 0.5));
            testCase.verifyLessThanOrEqual(max(T3K), ...
                GT_SIM.GT.limits.T3_design_K + ...
                GT_SIM.temperature_limit_tol_K);
            testCase.verifyLessThanOrEqual(abs(speedErrorRpm(end)), ...
                GT_SIM.final_speed_error_rpm);
            testCase.verifyLessThanOrEqual( ...
                max(abs(speedErrorRpm(afterStep))), ...
                GT_SIM.max_speed_error_rpm);
            testCase.verifyLessThanOrEqual( ...
                max(NggRpm(last10)) - min(NggRpm(last10)), 1e-3);
            testCase.verifyGreaterThanOrEqual(min(WfCmd), ...
                GT_SIM.Wf_min_kgps - 1e-12);
            testCase.verifyLessThanOrEqual(max(WfCmd), ...
                GT_SIM.Wf_max_kgps + 1e-12);
        end
    end
end

function modelPath = ensureModelBuilt(model)
packageRoot = fileparts(fileparts(mfilename('fullpath')));
modelPath = fullfile(packageRoot, 'simulink', [model '.slx']);
if ~isfile(modelPath)
    build_gt_component_native_model();
end
end
