# Deliverable Definition

## Purpose

For AI-assisted gas turbine modeling, define the minimum artifacts before claiming a model is complete. A diagram or a running simulation is not enough.

Before reporting completion, classify maturity using `model-maturity-and-delivery.md`. A MATLAB ODE baseline, a Simulink wrapper, and a native component-level Simulink plant are different deliverables.

For fillable stage-gate, loop-contract, initial-condition, validation, and repair-report tables, use `modeling-output-templates.md`.

## Design-Point Deliverables

A complete design-point stage should include:

- Confirmed application, architecture, working-fluid assumptions, dynamic depth, and control objective.
- Formula evidence table for equations not supplied directly by the user.
- MATLAB script or equivalent calculation artifact.
- Input requirement table.
- State-point table with pressure, temperature, flow, fluid type, and units.
- Component work and efficiency table.
- Fuel flow, air flow, fuel-air ratio, and cooling or bleed coefficients.
- Iteration variables, initial guesses, convergence tolerance, and convergence result.
- Comparison to any book example, hand calculation, or trusted baseline if available.

## Design-Point To Steady Mapping

Before building a steady-state model, create a mapping table:

| Design-point quantity | Steady model role | Dynamic model role | Unit | Source |
| --- | --- | --- | --- | --- |
| Rated air flow | Rated input or normalization basis | Initial map flow/reference flow | kg/s | design-point solver |
| Rated fuel flow | Rated input | Fuel initial condition | kg/s | design-point solver |
| Compressor pressure ratios | Parameter or map reference | Initial pressure ratios | dimensionless | design-point solver |
| Component efficiencies | Parameter or map reference | Map or loss reference | dimensionless | design-point solver |
| Shaft speeds | Parameter or map reference | Rotor initial conditions | rpm | design data or design point |
| State pressures | Output check | Volume pressure initial conditions | Pa or MPa | state table |
| State temperatures | Output check | Component or combustor initial conditions | K | state table |
| Cooling or bleed coefficients | System parameters | Cooling/mixing flow calculation | dimensionless | design-point solver |

Every quantity used as a dynamic initial condition or normalization constant should appear in this mapping.

## Steady-State Deliverables

A complete steady-state stage should include:

- Simulink model or subsystem list.
- Physical inputs such as air flow, fuel flow, ambient state, and fixed parameters.
- Output table for pressures, temperatures, component works, turbine inlet temperature, and output power.
- Rated-case comparison to the design point.
- List of assumptions retained from design point, such as fixed pressure ratios or fixed efficiencies.
- List of algebraic feedback paths and their initial values if Simulink uses memory or delay for iteration.

## Dynamic Model Deliverables

A dynamic gas turbine plant should include:

- Main dynamic `.slx` model.
- Design-point MATLAB or table artifact used for initialization.
- Steady-state rated-case validation artifact.
- Characteristic-map data and fitted model files used by Simulink.
- Dynamic iteration map.
- Loop-by-loop build log.
- Initial-condition registry.
- Solver and sample-time record.
- Validation run with rated initialization residuals.
- At least one controlled transient or open-loop perturbation case, if transient behavior is part of the task.
- Trim or steady-initialization record when design-point initial values do not close residuals.
- Maturity label such as V0 MATLAB baseline, V1 Simulink wrapper, V2 native component plant, V3 scenario-ready model, or V4 calibrated model.

For a final V2+ component plant, core compressor, combustor, turbine, volume, rotor, fuel-actuator, and load equations should be visible as component-level Simulink logic rather than hidden inside MATLAB Function, Fcn, Interpreted MATLAB Function, or black-box S-Function blocks unless the user explicitly accepts a partially opaque component.

## Minimum Dynamic Plant Contents

Define the minimum plant contents from the confirmed architecture. For the default three-shaft reference case, unless the user asks for a reduced model, the plant should contain:

- Low-pressure compressor map and work calculation.
- High-pressure compressor map and work calculation.
- Combustor mass and energy calculation or explicitly documented thermal lag.
- High-pressure turbine map and work calculation.
- Low-pressure turbine map and work calculation.
- Power turbine map and work calculation.
- Low-pressure shaft state.
- High-pressure shaft state.
- Power shaft state.
- At least the inter-component pressure states required by the iteration map.
- Fuel input path and load input path.
- Map range or saturation monitoring.

If any item is omitted, state that the model is reduced and identify what behavior cannot be trusted.

For single-shaft, two-shaft, propulsion, mechanical-drive, recuperated, intercooled, reheated, or hybrid systems, create the equivalent minimum-content list after scope triage. Do not force the three-shaft component list onto a different architecture.

## Control Deliverables

When a controller is part of the task, include:

- Confirmed application branch and control objective.
- Plant validation evidence before controller integration.
- Controlled variable, manipulated variable, actuator dynamics, limits, and sensors.
- Controller structure and source or tuning method.
- Validation scenarios such as speed command, fuel step, load step, grid disturbance, or thrust command.
- Evidence that control action does not hide invalid plant initialization.

## Validation Report Format

For each validation report, include:

| Field | Required content |
| --- | --- |
| Model file | `.m`, `.slx`, `.mat`, and data files used |
| Scenario | Rated initialization, fuel step, load step, or other |
| Initial conditions | Registry version or table |
| Inputs | Ambient, fuel, load, speed, IGV, or controller schedule |
| Solver | Solver type, step size, stop time |
| Tolerances | Pressure, temperature, flow, power, acceleration, and residual tolerances |
| Key results | State table, shaft speeds, powers, pressure derivatives, map margins |
| Pass/fail | Explicit result with unresolved issues |

## Operating Matrix Deliverable

For V3 or any model intended for controls or scenario analysis, include an operating matrix rather than a single rated run:

| Scenario | Purpose |
| --- | --- |
| Rated initial residual | Verify design-point closure and state derivatives |
| Load rejection/unload | Check overspeed, fuel reduction, and map validity |
| Load step-up | Check acceleration, fuel limit, temperature response, and pressure transients |
| Fuel step or actuator test | Verify plant response independent of controller tuning |
| Speed command perturbation | Check controller response after open-loop plant validation |
| Multiple steady load levels | Check off-design convergence and map operating range |
| Near map boundary | Check `map_valid`, surge margin, saturation, and extrapolation behavior |
| Long hold | Check slow drift of pressure, speed, temperature, and fuel states |
