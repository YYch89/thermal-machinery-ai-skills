classdef audit_gt_mapsTest < matlab.unittest.TestCase
    %AUDIT_GT_MAPSTEST Tests for read-only map audit data.

    methods (TestClassSetup)
        function addSourceToPath(testCase)
            testFolder = fileparts(mfilename('fullpath'));
            packageRoot = fileparts(testFolder);
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                fullfile(packageRoot, 'src')));
        end
    end

    methods (Test)
        function testSyntheticCompressorMapIsAvailable(testCase)
            audit = audit_gt_maps();

            testCase.verifyTrue(audit.compressor.xpi.exists);
            testCase.verifyFalse(audit.compressor.localMassFlow.exists);
            testCase.verifyFalse(audit.compressor.localEfficiency.exists);
            testCase.verifyFalse(audit.compressor.localHighSpeedWorkbook.exists);
            testCase.verifyEqual(audit.compressor.files.xpi, ...
                'synthetic_public_compressor_map');
        end

        function testCompressorDesignPointIsInsideXpiRange(testCase)
            audit = audit_gt_maps();

            testCase.verifyEqual(audit.compressor.design.pi_map, ...
                audit.compressor.scaling.local_pi_map_dp, 'AbsTol', 1e-10);
            testCase.verifyTrue(audit.compressor.design.within_xpi_range);
            testCase.verifyTrue(audit.compressor.map_valid_at_design);
        end

        function testEfficiencyFallbackIsExplicit(testCase)
            audit = audit_gt_maps();

            testCase.verifyFalse(audit.compressor.design.efficiency_map_can_use_design_flow);
            testCase.verifyEqual(audit.compressor.efficiency_source, ...
                'constant_fallback_until_efficiency_map_is_rebased');
        end

        function testTurbineFallbackIsStodola(testCase)
            audit = audit_gt_maps();

            testCase.verifyEqual(audit.turbine.primary, 'stodola_flugel');
            testCase.verifyGreaterThan(audit.turbine.K_TG, 0);
            testCase.verifyGreaterThan(audit.turbine.K_PT, 0);
            testCase.verifyTrue(audit.turbine.map_valid_at_design);
        end

        function testMapAuditIsReadyForSteadyRated(testCase)
            audit = audit_gt_maps();

            testCase.verifyTrue(audit.summary.ready_for_steady_map_rated);
            testCase.verifyTrue(audit.summary.compressor_efficiency_uses_fallback);
            testCase.verifyTrue(audit.summary.turbine_uses_stodola);
        end
    end
end
