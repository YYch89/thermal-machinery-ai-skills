# Model Maturity and Delivery Levels

## Purpose

Use this file to classify how mature a gas turbine model is. A model that runs is not necessarily a component-level dynamic plant. Do not overstate maturity.

## Maturity Levels

| Level | Name | Purpose | Acceptable implementation | Completion evidence |
| --- | --- | --- | --- | --- |
| V0 | MATLAB dynamic equation baseline | Test state equations, signs, residuals, and simple control logic quickly | MATLAB scripts/functions, ODE functions, tables | Design-point residuals, state derivative checks, simple transient plots |
| V1 | Simulink wrapper validation platform | Exercise plant equations in Simulink and connect basic controller/load paths | MATLAB Function, Interpreted MATLAB Function, Fcn, or wrapper subsystem may be used if labeled | Same numerical behavior as V0, short transient sanity check, clear warning that core physics is wrapped |
| V2 | Native component-level Simulink plant | Make formulas, signals, states, and feedback visible and auditable in Simulink | Prefer primitive Simulink blocks, documented lookup tables, visible arithmetic, explicit state blocks | Component interfaces, loop contracts, initial-condition registry, rated residuals, long simulation stability |
| V3 | Map/protection/operating-matrix model | Add map validity, protection logic, actuator/sensor limits, operating scenarios | Component-level plant plus valid-domain logic, limiters, schedules, scenario tests | Operating matrix, map-valid logs, protection behavior, long-run drift checks |
| V4 | Calibrated or evidence-backed model | Support publication, controls study, or engineering decisions | V3 plus literature/test calibration and traceable uncertainty | Comparison to test/literature data, calibrated parameters, documented error bounds |

When reporting a result, state the maturity level explicitly. Do not call V0 or V1 a final Simulink plant.

## Core Physics Visibility Rule

For final component-level delivery, core plant physics should not be hidden in opaque blocks.

Avoid using these blocks to encapsulate compressor, combustor, turbine, volume, rotor, fuel actuator, or load physics in a final V2+ plant unless the user explicitly approves the tradeoff:

- MATLAB Function
- Interpreted MATLAB Function
- Fcn
- large masked subsystem with undocumented equations
- black-box S-Function

Allowed uses:

- Design-point solvers.
- V0 numerical baseline.
- V1 wrapper validation.
- Auto-generation scripts that build native Simulink blocks.
- Small utility functions when their equations, units, inputs, outputs, and validation are documented.

If an opaque block remains in V2+, mark the component as partially opaque and include a reason, source equations, and verification evidence.

## Completion Definition

A dynamic gas turbine model is not complete because it simulates for a few seconds. Completion requires:

- Design-point closure.
- Dynamic initial residual checks.
- Map operating points inside valid domains.
- Long simulation with no slow drift or nonphysical state.
- Operating matrix covering representative load, fuel, command, and boundary scenarios.
- Clear maturity label and unresolved limitations.

## Stage-Gate Language

Use precise status labels:

- `planned`: requirements and sources identified, no executable model yet.
- `V0 baseline`: MATLAB dynamic equations run and residuals are understood.
- `V1 wrapper`: Simulink can run, but core physics may be hidden.
- `V2 component plant`: Simulink component model is visible and auditable.
- `V3 scenario-ready`: maps, protections, long simulation, and operating matrix are checked.
- `V4 calibrated`: compared with trusted external data.

Do not use `validated`, `final`, or `engineering-ready` unless the evidence matches the label.

