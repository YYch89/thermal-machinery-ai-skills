classdef evaluate_gt_dynamicsTest < matlab.unittest.TestCase
    %EVALUATE_GT_DYNAMICSTEST Tests for dynamic plant initialization.

    methods (TestClassSetup)
        function addSourceToPath(testCase)
            testFolder = fileparts(mfilename('fullpath'));
            packageRoot = fileparts(testFolder);
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                fullfile(packageRoot, 'src')));
        end
    end

    methods (Test)
        function testInitialConditionRegistry(testCase)
            GT = build_gt_model_data();
            ic = build_gt_dynamic_initial_condition(GT);

            testCase.verifyEqual(numel(ic.x0), 6);
            testCase.verifyEqual(numel(ic.stateNames), 6);
            testCase.verifyEqual(numel(ic.registry), 6);
            testCase.verifyEqual(ic.x0(1), GT.init.omega_GG0_radps, ...
                'AbsTol', 1e-12);
            testCase.verifyEqual(ic.x0(2), GT.init.omega_PT0_radps, ...
                'AbsTol', 1e-12);
            testCase.verifyEqual(ic.u0.P_dc_load_W, GT.req.P_dc_rated_W, ...
                'AbsTol', 1e-9);
        end

        function testDynamicInitialDerivativesAreNearZero(testCase)
            GT = build_gt_model_data();
            ic = build_gt_dynamic_initial_condition(GT);
            [xdot, y] = evaluate_gt_dynamics(0, ic.x0, ic.u0, GT);

            testCase.verifyEqual(xdot(1), 0, 'AbsTol', 1e-9);
            testCase.verifyEqual(xdot(2), 0, 'AbsTol', 1e-9);
            testCase.verifyEqual(xdot(3), 0, 'AbsTol', 1e-6);
            testCase.verifyEqual(xdot(4), 0, 'AbsTol', 1e-6);
            testCase.verifyEqual(xdot(5), 0, 'AbsTol', 1e-10);
            testCase.verifyEqual(xdot(6), 0, 'AbsTol', 1e-12);
            testCase.verifyTrue(y.checks.all_passed);
        end

        function testDynamicResidualsAreNearZero(testCase)
            GT = build_gt_model_data();
            ic = build_gt_dynamic_initial_condition(GT);
            [~, y] = evaluate_gt_dynamics(0, ic.x0, ic.u0, GT);

            residualVector = [ ...
                y.residuals.P3_flow_rel, ...
                y.residuals.P4_flow_rel, ...
                y.residuals.GG_power_balance_rel, ...
                y.residuals.PT_power_balance_rel, ...
                y.residuals.T3_eq_rel, ...
                y.residuals.fuel_actuator_rel];

            testCase.verifyLessThan(max(abs(residualVector)), 1e-10);
            testCase.verifyTrue(y.checks.compressor_map_valid);
        end

        function testDcPowerLoadModeMatchesRatedShaftPower(testCase)
            GT = build_gt_model_data();
            ic = build_gt_dynamic_initial_condition(GT);
            [~, y] = evaluate_gt_dynamics(0, ic.x0, ic.u0, GT);

            testCase.verifyEqual(y.load.Pload_shaft_W, ...
                GT.req.P_PT_shaft0_W, 'RelTol', 1e-12);
            testCase.verifyEqual(y.load.Tload_Nm, GT.init.Tload0_Nm, ...
                'RelTol', 1e-12);
            testCase.verifyEqual(y.load.mode, 'dc_power');
        end

        function testTorqueLoadModeMatchesRatedShaftPower(testCase)
            GT = build_gt_model_data();
            ic = build_gt_dynamic_initial_condition(GT);
            u = ic.u0;
            u.loadMode = 'torque';
            [~, y] = evaluate_gt_dynamics(0, ic.x0, u, GT);

            testCase.verifyEqual(y.load.Pload_shaft_W, ...
                GT.req.P_PT_shaft0_W, 'RelTol', 1e-12);
            testCase.verifyEqual(y.residuals.PT_power_balance_rel, 0, ...
                'AbsTol', 1e-12);
        end
    end
end
