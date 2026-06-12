classdef evaluate_gt_steady_ratedTest < matlab.unittest.TestCase
    %EVALUATE_GT_STEADY_RATEDTEST Tests for the rated steady map wrapper.

    methods (TestClassSetup)
        function addSourceToPath(testCase)
            testFolder = fileparts(mfilename('fullpath'));
            packageRoot = fileparts(testFolder);
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                fullfile(packageRoot, 'src')));
        end
    end

    methods (Test)
        function testCompressorMapReproducesRatedFlow(testCase)
            GT = build_gt_model_data();
            steady = evaluate_gt_steady_rated(GT);

            testCase.verifyTrue(steady.compressor.map_valid);
            testCase.verifyEqual(steady.compressor.W_air_kgps, ...
                GT.design.state.W_air_kgps, 'RelTol', 1e-12);
            testCase.verifyEqual(steady.residuals.compressor_flow_rel, ...
                0, 'AbsTol', 1e-12);
        end

        function testCombustorEnergyReproducesT3(testCase)
            GT = build_gt_model_data();
            steady = evaluate_gt_steady_rated(GT);

            testCase.verifyEqual(steady.combustor.T3_K, ...
                GT.design.state.T3_K, 'AbsTol', 1e-9);
            testCase.verifyEqual(steady.combustor.fuel_air_ratio, ...
                GT.design.perf.fuel_air_ratio, 'RelTol', 1e-12);
        end

        function testStodolaTurbineFlowsClose(testCase)
            GT = build_gt_model_data();
            steady = evaluate_gt_steady_rated(GT);

            testCase.verifyEqual(steady.gasGeneratorTurbine.W_turbine_kgps, ...
                steady.combustor.W_gas_kgps, 'RelTol', 1e-12);
            testCase.verifyEqual(steady.powerTurbine.W_turbine_kgps, ...
                steady.combustor.W_gas_kgps, 'RelTol', 1e-12);
            testCase.verifyLessThan(abs(steady.residuals.TG_flow_rel), 1e-12);
            testCase.verifyLessThan(abs(steady.residuals.PT_flow_rel), 1e-12);
        end

        function testPowerBalancesClose(testCase)
            GT = build_gt_model_data();
            steady = evaluate_gt_steady_rated(GT);

            testCase.verifyLessThan(abs( ...
                steady.residuals.GG_power_balance_rel), 1e-12);
            testCase.verifyLessThan(abs( ...
                steady.residuals.PT_power_balance_rel), 1e-12);
            testCase.verifyLessThan(abs(steady.residuals.DC_power_rel), 1e-12);
        end

        function testRatedSteadyChecksPass(testCase)
            GT = build_gt_model_data();
            steady = evaluate_gt_steady_rated(GT);

            testCase.verifyEqual(steady.stage, 'steady_map_rated');
            testCase.verifyTrue(steady.checks.map_audit_ready);
            testCase.verifyTrue(steady.checks.all_passed);
        end
    end
end
