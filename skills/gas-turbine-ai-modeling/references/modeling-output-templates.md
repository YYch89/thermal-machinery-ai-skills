# Modeling Output Templates

## Purpose

Use these templates to keep gas turbine modeling outputs auditable. The agent may adapt the tables to the architecture, but should preserve the evidence fields.

## Stage Gate Summary

| Stage | Artifact | Status | Evidence | User confirmation |
| --- | --- | --- | --- | --- |
| Requirements intake | Intake table and assumptions |  |  |  |
| Formula evidence | Equation/source table |  |  |  |
| Design point | MATLAB solver or equivalent |  |  |  |
| Simulink design point | Block model matching design solver |  |  |  |
| Steady plant | Input-output thermodynamic model |  |  |  |
| Dynamic plant | Rotor/volume/combustor/map loops |  |  |  |
| Control | Controller integrated after plant validation |  |  |  |
| Validation | Scenario matrix and long-run report |  |  |  |

## Requirement And Assumption Record

| Item | Value | Unit | Source | Status |
| --- | --- | --- | --- | --- |
| Application |  |  | user/file/assumption |  |
| Architecture |  |  | user/file/assumption |  |
| Rated power or thrust |  |  | user/file/assumption |  |
| Pressure ratio |  |  | user/file/assumption |  |
| Turbine inlet or combustor outlet temperature |  |  | user/file/assumption |  |
| Fuel LHV |  |  | user/file/assumption |  |
| Working-fluid model |  |  | user/file/literature/assumption |  |
| Control objective |  |  | user/file/assumption |  |

## Formula Evidence Table

| Component | Equation or model family | Variables | Units | Source category | Applicability | Validation check |
| --- | --- | --- | --- | --- | --- | --- |
| Compressor |  |  |  | user/literature/template/open-source/assumption |  |  |
| Combustor |  |  |  | user/literature/template/open-source/assumption |  |  |
| Turbine |  |  |  | user/literature/template/open-source/assumption |  |  |
| Volume |  |  |  | user/literature/template/open-source/assumption |  |  |
| Rotor |  |  |  | user/literature/template/open-source/assumption |  |  |
| Map |  |  |  | user/literature/template/open-source/assumption |  |  |

## Design-Point State Table

| Station | Description | Fluid | Pressure | Temperature | Mass flow | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| 0 | Ambient/inlet |  |  |  |  |  |
| 1 | Compressor inlet |  |  |  |  |  |
| 2 | Compressor outlet or inter-stage |  |  |  |  |  |
| 3 | Combustor outlet or turbine inlet |  |  |  |  |  |
| 4 | Turbine outlet or inter-stage |  |  |  |  |  |
| 5 | Exhaust or load turbine outlet |  |  |  |  |  |

Add or rename stations to match the actual engine architecture.

## Design-To-Dynamic Mapping

| Design-point quantity | Dynamic role | Block or parameter | Initial value | Unit | Source | Check |
| --- | --- | --- | --- | --- | --- | --- |
| Rated air flow | Map reference or input |  |  | kg/s |  | flow match |
| Rated fuel flow | Fuel state or input |  |  | kg/s |  | combustor residual |
| Shaft speed | Rotor IC |  |  | rpm or rad/s |  | acceleration near zero |
| Inter-component pressure | Volume pressure IC |  |  | Pa or MPa |  | `dP/dt` near zero |
| Turbine inlet temperature | Combustor/thermal IC |  |  | K |  | `dT/dt` near zero |

## Dynamic Loop Contract

| Field | Content |
| --- | --- |
| Loop name |  |
| Physical state |  |
| State equation |  |
| Inputs |  |
| Outputs |  |
| Feedback destination |  |
| Initial value and source |  |
| Unit conversion |  |
| Zero-derivative check |  |
| Isolation test |  |
| Validation result |  |

Create one contract per rotor, volume, combustor, map feedback, actuator, and load loop.

## Initial-Condition Registry

| Path | Block type | State or signal | Initial value | Unit | Source | First-step check | Residual check |
| --- | --- | --- | --- | --- | --- | --- | --- |
|  | Memory/Delay/Unit Delay/Integrator/etc. |  |  |  | design/trim/tuned |  |  |

Every stateful block in the dynamic causal path must appear here.

## Validation Report

| Field | Required content |
| --- | --- |
| Model files | `.m`, `.slx`, `.mat`, map data, scripts |
| Maturity label | V0 MATLAB baseline, V1 wrapper, V2 native component plant, V3 scenario-ready, or V4 calibrated |
| Evidence level | `exploratory`, `reduced`, `design-point checked`, `dynamic-initialization checked`, or `calibrated/externally validated` |
| Scenario | Rated initialization, load step, fuel step, speed command, thrust command, repair verification, etc. |
| Initial condition source | Design point, trim, steady solve, or temporary assumption |
| Solver and time settings | Solver, step size, StopTime, logging |
| Tolerances | Pressure, temperature, flow, power, shaft acceleration, pressure derivative, map error |
| Key residuals | mass balance, fuel/air/species or element balance, component and whole-system energy, pressure path, rotor power, volume flow, combustor energy, map consistency |
| Long-run checks | Final-window slopes, `map_valid`, saturation activity, nonphysical states |
| Pass/fail | Explicit result and unresolved issues |

## Repair Report Addendum

Use this addendum when the task is to fix an existing model:

| Item | Content |
| --- | --- |
| Original failure time |  |
| Reported block |  |
| First nonphysical signal |  |
| Upstream causal path |  |
| Root cause classification | Equation, IC, map, unit, controller/load, solver, or protection |
| Temporary experiment |  |
| Fixed copy path |  |
| Validation ladder | `0.01 s -> 1 s -> 10 s -> 50 s -> long run` |
| Remaining risk |  |
