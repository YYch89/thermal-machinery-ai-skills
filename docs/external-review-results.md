# External Review Results

Date: 2026-06-12

Scope: pre-release review of the public candidate repository.

## Review Summary

Initial external-style review covered four passes:

- privacy and publication safety;
- skill usability;
- engineering safety and claims;
- blind skill test using `thermal-machinery-dynamic-modeling`.

After the public scope changed to remove sensitive-domain artifacts and add a
synthetic gas-turbine dynamic example, a follow-up local review was run for:

- sensitive-term and path leakage;
- blocked binary and private data file types;
- skill packaging validity;
- README, privacy, release, and example consistency;
- engineering-claim wording.

No privacy or packaging publication blocker was found.

## Findings Addressed Before Release

- Added a copyright holder to `LICENSE`.
- Expanded blocked binary/research asset extensions in `scripts/validate_release.py`.
- Changed release-check wording from "validation" to repository release checks, to avoid confusion with engineering validation.
- Added root `AGENTS.md` with repository agent rules.
- Added README guidance on which skill to use.
- Added compact artifact templates for `thermal-machinery-dynamic-modeling`.
- Standardized `agents/openai.yaml` schema.
- Added minimum reference bundles to `gas-turbine-ai-modeling`.
- Linked Simulink fallback guidance from the gas-turbine skill.
- Strengthened gas-turbine validation gates for mass, species/element, energy, pressure path, map-domain, and dynamic-initialization checks.
- Replaced broad `validated` status labels with evidence-specific labels.
- Added a synthetic non-gas-turbine heat-pump ledger example.
- Removed sensitive-domain workflow artifacts from the public candidate scope.
- Added a self-contained synthetic dual-shaft gas-turbine dynamic example.
- Tightened `.gitignore` and release checks for generated Simulink model
  outputs and backup names.
- Updated privacy notes to reflect public MATLAB `.m` example code.
- Softened gas-turbine example wording from validation claims to smoke-check
  language where runtime evidence has not been completed.

## Deferred Ideas

- Add more synthetic examples for Rankine, refrigeration, and recuperated Brayton systems.
- Add schema tests for CSV artifact columns.
- Add more public gas-turbine examples for alternate controllers and shaft arrangements.

## Current Decision

Privacy and packaging checks show no publication blocker for a `v0.1.0`
public release.

The synthetic gas-turbine MATLAB/Simulink example has since been smoke-check
verified with MATLAB/Simulink R2023a:

- core MATLAB design/steady/dynamic checks completed;
- `runtests('tests')` completed;
- README Simulink build and closed-loop scripts completed;
- generated `.slx`, `.slxc`, `.mat`, and cache artifacts were removed after
  verification and remain excluded from the public package.

The repository remains a public-preview research workflow package, not a
certified engineering simulator.
