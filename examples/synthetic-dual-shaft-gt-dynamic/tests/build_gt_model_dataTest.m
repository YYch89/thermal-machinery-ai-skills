classdef build_gt_model_dataTest < matlab.unittest.TestCase
    %BUILD_GT_MODEL_DATATEST Tests for the design-point data package.

    methods (TestClassSetup)
        function addSourceToPath(testCase)
            testFolder = fileparts(mfilename('fullpath'));
            packageRoot = fileparts(testFolder);
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                fullfile(packageRoot, 'src')));
        end
    end

    methods (Test)
        function testRatedDesignPoint(testCase)
            GT = build_gt_model_data();

            testCase.verifyEqual(GT.design.state.W_air_kgps, ...
                50.93091449636757, 'AbsTol', 1e-9);
            testCase.verifyEqual(GT.design.state.W_fuel_kgps, ...
                1.2512975605180878, 'AbsTol', 1e-9);
            testCase.verifyEqual(GT.design.state.T3_K, 1440, 'AbsTol', 1e-12);
            testCase.verifyEqual(GT.design.perf.P_PT_shaft_W, ...
                GT.req.P_PT_shaft0_W, 'AbsTol', 1e-6);
        end

        function testPowerBalances(testCase)
            GT = build_gt_model_data();

            testCase.verifyLessThan(GT.checks.GG_balance_rel, 1e-12);
            testCase.verifyLessThan(GT.checks.PT_balance_rel, 1e-12);
            testCase.verifyTrue(GT.checks.pressure_order);
            testCase.verifyTrue(GT.checks.temperature_order);
        end

        function testSweepIncludesNominalPoint(testCase)
            GT = build_gt_model_data();

            testCase.verifyTrue(any(GT.sweep.pi_c == GT.req.pi_c_nominal));
            testCase.verifyEqual(max(GT.sweep.Wpt_specific_J_kg_air), ...
                GT.sweep.Wpt_specific_J_kg_air(GT.sweep.pi_c == 14), ...
                'AbsTol', 1e-9);
        end

        function testInitialConditions(testCase)
            GT = build_gt_model_data();

            testCase.verifyEqual(GT.init.omega_GG0_radps, ...
                1256.6370614359173, 'AbsTol', 1e-9);
            testCase.verifyEqual(GT.init.omega_PT0_radps, ...
                314.1592653589793, 'AbsTol', 1e-9);
            testCase.verifyEqual(GT.init.Tload0_Nm, ...
                GT.req.P_PT_shaft0_W/GT.init.omega_PT0_radps, 'AbsTol', 1e-9);
            testCase.verifyGreaterThan(GT.dyn.V3_m3, 0);
            testCase.verifyGreaterThan(GT.dyn.V4_m3, 0);
        end

        function testChecksPass(testCase)
            GT = build_gt_model_data();

            testCase.verifyTrue(GT.checks.all_passed);
            testCase.verifyEqual(GT.checks.model_level, 'exploratory_reduced');
        end
    end
end
