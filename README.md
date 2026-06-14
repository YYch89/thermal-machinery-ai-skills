# Thermal Machinery AI Skills

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.20666571.svg)](https://doi.org/10.5281/zenodo.20666571)

[English](README.md) | [简体中文](README.zh-CN.md)

AI-agent workflows for staged dynamic modeling of gas turbines and coupled thermal-machinery systems.

This repository provides open Codex skills, modeling procedures, validation checklists, and runnable synthetic examples that help AI agents move from engineering requirements to design-point calculation, steady-state closure, dynamic initialization, Simulink implementation, and smoke-check validation.

It is one of the early open skillsets focused on AI-assisted dynamic modeling for complex thermal-machinery systems. The first public runtime example is a synthetic dual-shaft gas-turbine model verified with MATLAB/Simulink R2023a.

The general thermal-machinery workflow now explicitly asks agents to define the model depth and simplification level, treat topology as a design variable, check heat grade and pressure compatibility, and verify physical control authority before claiming dynamic or control behavior.

Not just prompts. Not just code generation.
This project turns domain modeling experience into reusable AI-agent workflows.

## Citation

If you use this project, please cite:

```text
Wen, J. (2026). Thermal Machinery AI Skills (v0.1.1) [Software]. Zenodo. https://doi.org/10.5281/zenodo.20666571
```

## Why This Exists

Large language models can write equations and scripts quickly, but complex thermal systems fail when the modeling process is not staged. Gas turbines, heat engines, refrigeration cycles, and hybrid thermal systems require traceable assumptions, component contracts, node-by-node stream accounting, dynamic initial conditions, map validity checks, and validation gates.

These skills teach an AI agent to slow down, build the model in layers, and keep every pressure, temperature, mass flow, composition, power balance, state, and assumption auditable.

## Modeling Principles

The public skills emphasize a few general rules that apply across thermal-machinery domains:

- Define a model-depth and simplification contract before implementation: concept, design point, executable design reproduction, steady plant, reduced dynamic plant, detailed dynamic plant, or controlled/optimized plant.
- Treat topology as a design variable, not only a diagram. Component order, split/merge paths, heat recovery, pressure levels, shafts, loads, and actuator paths can make a system feasible or infeasible.
- Check energy quality as well as energy balance. A model can conserve total energy while wasting high-grade heat on a low-grade duty or imposing an impossible heat-exchanger terminal temperature.
- Separate reduced closure from detailed dynamics. Equilibrium, steady correlations, reduced progress states, and inventory-based dynamic states require different evidence.
- Verify control authority. A controller is meaningful only when the selected topology contains a physical actuator, load, shaft, heat source, valve, electric device, or storage term that can influence the controlled variable.
- Do not claim validation from a successful simulation alone. Validation requires balances, initial residuals, data provenance, constraints, and stated tolerances.

## Included Skills

### `thermal-machinery-dynamic-modeling`

General workflow skill for dynamic thermodynamic systems. It guides an AI agent through:

- scope and requirement triage;
- model-depth and simplification contracts;
- topology and node-ledger construction;
- heat-grade, pressure-compatibility, and actuator-authority checks;
- component contracts and stream interfaces;
- design-point and steady-state consistency checks;
- dynamic-state selection and initialization;
- validation gates before control or optimization.

Use it for heat engines, power cycles, compressors, turbines, pumps, fans, combustors, reactors, heat exchangers, recuperators, mixers, Brayton cycles, Rankine cycles, refrigeration systems, heat pumps, and hybrid thermal systems.

### `gas-turbine-ai-modeling`

Domain skill for staged gas-turbine modeling, especially multi-shaft gas turbines. It focuses on:

- design-point calculation and state tables;
- MATLAB-to-Simulink staging;
- compressor and turbine characteristic maps;
- rotor, volume, and combustor dynamics;
- initial-condition registries and trim checks;
- control integration after plant initialization;
- validation and repair of dynamic Simulink models.

## Public Examples

### Synthetic Dual-Shaft Gas Turbine

`examples/synthetic-dual-shaft-gt-dynamic` contains a self-contained public gas-turbine dynamic example with:

- MATLAB design-point data source;
- synthetic compressor-map data;
- rated steady map-wrapper closure;
- reduced dynamic plant equations;
- Simulink model-generation scripts;
- native-block component Simulink model generation;
- MATLAB unit tests and runtime smoke checks;
- component contracts and validation notes.

The example is exploratory and reduced. It is designed to demonstrate an auditable modeling workflow, not to represent a certified engine or manufacturer model.

Runtime smoke checks have been verified with MATLAB/Simulink R2023a:

```text
R2023_PUBLIC_GT_CORE_CHECKS_PASSED
R2023_PUBLIC_GT_RUNTTESTS_PASSED
R2023_PUBLIC_GT_README_SCRIPTS_COMPLETED
```

### Synthetic Heat-Pump Ledger

`examples/synthetic-heat-pump-ledger` provides a compact non-gas-turbine example for the general thermal-machinery workflow, focused on topology, node ledgers, stream variables, and validation boundaries.

## Which Skill Should I Use?

| Situation | Recommended skill use |
| --- | --- |
| New thermal system or mixed energy-conversion topology | Start with `thermal-machinery-dynamic-modeling` for scope, topology, node ledger, component contracts, initialization, and validation gates. |
| Gas turbine design-point, dynamic plant, map fitting, rotor/volume dynamics, or Simulink repair | Use `gas-turbine-ai-modeling`. |
| Integrated systems that include a gas turbine plus other thermal components | Use `thermal-machinery-dynamic-modeling` for whole-system topology and stream ledgers, then `gas-turbine-ai-modeling` for the gas-turbine subsystem. |
| Quick external review of a proposed model | Use the relevant domain skill, then check outputs against the validation and deliverable references. |

## Quick Start

Copy a skill folder into your Codex skills directory, or reference this repository from a workspace where Codex can load skills.

For a new thermal system:

```text
Use the thermal-machinery-dynamic-modeling skill to plan a dynamic model.
Start with scope, model-depth contract, topology, node ledger, component contracts, dynamic initialization, and validation gates.
```

For a gas turbine:

```text
Use the gas-turbine-ai-modeling skill to build a staged design-point to dynamic modeling workflow.
Do not jump directly to Simulink. Produce state tables, loop contracts, initial-condition registry, and validation gates.
```

To run the public gas-turbine example from MATLAB:

```matlab
runtests('tests')
run('scripts/build_gt_simulink_model.m')
run('scripts/run_simulink_closed_loop.m')
run('scripts/build_gt_component_native_model.m')
run('scripts/run_component_native_closed_loop.m')
```

The Simulink models are generated locally by scripts and are not committed to the repository.

## What This Project Is Not

This repository is not a certified engineering simulator, manufacturer model, performance guarantee, or replacement for domain review. It does not include proprietary maps, private calibration data, unpublished project models, or safety-critical certification artifacts.

The skills provide modeling discipline, artifact templates, and validation gates. Engineering use still requires source-backed equations, component data, experimental or manufacturer validation, and professional review.

## Release Checks

Before publishing or tagging a release, run:

```bash
python scripts/validate_release.py
```

These checks cover repository structure, privacy, and packaging. They do not validate engineering correctness.

For independent review prompts, see `docs/external-review-prompts.md`.

## Repository Layout

```text
skills/
  thermal-machinery-dynamic-modeling/
  gas-turbine-ai-modeling/
examples/
  synthetic-dual-shaft-gt-dynamic/
  synthetic-heat-pump-ledger/
docs/
  privacy-review.md
  release-checklist.md
  github-release-plan.md
```

## Maintainer Note

This project was initiated by an energy and power engineering PhD researcher who wants AI agents to participate in scientific modeling more rigorously: not by guessing complete models, but by following staged, auditable engineering workflows.

## License

MIT License. See `LICENSE`.
