classdef evaluate_gt_componentsTest < matlab.unittest.TestCase
    %EVALUATE_GT_COMPONENTSTEST Componentized plant equivalence tests.

    methods (TestClassSetup)
        function addSourceToPath(testCase)
            testFolder = fileparts(mfilename('fullpath'));
            packageRoot = fileparts(testFolder);
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                fullfile(packageRoot, 'src')));
        end
    end

    methods (Test)
        function testRatedInitialPointMatchesV0(testCase)
            GT = build_gt_model_data();
            ic = build_gt_dynamic_initial_condition(GT);

            [xdotV0, yV0] = evaluate_gt_dynamics(0, ic.x0, ic.u0, GT);
            [xdotComp, yComp] = evaluate_gt_components(0, ic.x0, ...
                ic.u0, GT);

            testCase.verifyEqual(xdotComp, xdotV0, 'AbsTol', 1e-12);
            testCase.verifyTrue(yComp.checks.all_passed);
            testCase.verifyEqual(yComp.compressor.W_air_kgps, ...
                yV0.compressor.W_air_kgps, 'RelTol', 1e-12);
            testCase.verifyEqual(yComp.powerTurbine.P_PT_shaft_W, ...
                yV0.powerTurbine.P_PT_shaft_W, 'RelTol', 1e-12);
        end

        function testPerturbedPointMatchesV0(testCase)
            GT = build_gt_model_data();
            ic = build_gt_dynamic_initial_condition(GT);
            x = ic.x0;
            x(1) = 0.995*x(1);
            x(2) = 1.002*x(2);
            x(3) = 0.995*x(3);
            x(4) = 1.003*x(4);
            x(5) = 0.998*x(5);
            x(6) = 0.990*x(6);
            u = ic.u0;
            u.P_dc_load_W = 0.97*u.P_dc_load_W;
            u.Wf_cmd_kgps = 0.992*u.Wf_cmd_kgps;

            [xdotV0, yV0] = evaluate_gt_dynamics(0, x, u, GT);
            [xdotComp, yComp] = evaluate_gt_components(0, x, u, GT);

            testCase.verifyEqual(xdotComp, xdotV0, 'RelTol', 1e-12, ...
                'AbsTol', 1e-8);
            testCase.verifyEqual(yComp.compressor.P_comp_W, ...
                yV0.compressor.P_comp_W, 'RelTol', 1e-12);
            testCase.verifyEqual(yComp.gasGeneratorTurbine.T4_K, ...
                yV0.gasGeneratorTurbine.T4_K, 'RelTol', 1e-12);
            testCase.verifyEqual(yComp.load.Pload_shaft_W, ...
                yV0.load.Pload_shaft_W, 'RelTol', 1e-12);
        end

        function testComponentBoundariesExposeExpectedSignals(testCase)
            GT = build_gt_model_data();
            ic = build_gt_dynamic_initial_condition(GT);
            [~, y] = evaluate_gt_components(0, ic.x0, ic.u0, GT);

            testCase.verifyEqual(y.stage, 'componentized_dynamic_plant');
            testCase.verifyTrue(isfield(y.compressor, 'P_comp_W'));
            testCase.verifyTrue(isfield(y.combustor, 'T3_eq_K'));
            testCase.verifyTrue(isfield(y.gasGeneratorTurbine, ...
                'P_TG_shaft_W'));
            testCase.verifyTrue(isfield(y.powerTurbine, 'P_PT_shaft_W'));
            testCase.verifyTrue(isfield(y.load, 'Tload_Nm'));
            testCase.verifyTrue(isfield(y.derivatives, 'P3_Paps'));
        end
    end
end
