# Requirements and Scope Triage

## Purpose

Gas turbine modeling depends strongly on application, architecture, working-fluid assumptions, and control objectives. Do not assume the model is a three-shaft power-generation plant unless the user says so.

Use this triage before choosing formulas, model structure, dynamic states, or control logic.

For a fillable intake table and modeling-mode decision record, use `requirements-intake-template.md`.

## Required Questions To Resolve

Clarify or extract these items from user materials:

| Area | What to determine |
| --- | --- |
| Application | Power generation, propulsion, mechanical drive, hybrid system, test rig, or educational model |
| Electrical or mechanical context | Grid-connected generator, islanded generator, free power turbine, propulsor, compressor load, pump load, or shaft load |
| Architecture | Single-shaft, two-shaft, three-shaft, free turbine, recuperated, intercooled, reheated, or other |
| Component coupling | Which turbine drives which compressor or load |
| Dynamic depth | Rotor only, volume pressures, combustor temperature/pressure, actuator, fuel system, sensor, controller |
| Control target | Shaft speed, grid frequency, output power, fuel schedule, thrust, turbine inlet temperature, surge margin, or load following |
| Working fluid | Ideal air/gas, variable heat capacity, combustion products, gas composition, cooling/mixing, humidity if relevant |
| Fuel and combustion | Fuel type, lower heating value, combustion efficiency, air-fuel relation, excess-air coefficient, emissions chemistry if required |
| Evidence source | User model, textbook, paper, standard, open-source implementation, or explicit assumption |

Ask concise follow-up questions when these items affect formulas or control structure. Do not hide critical assumptions.

## Temperature Limit Triage

When the user gives a temperature such as combustor outlet temperature or turbine inlet temperature, ask what kind of temperature it is:

- design-point target;
- continuous operating limit;
- transient limit;
- trip/protection limit;
- controller scheduling or fuel-limiter threshold.

Use distinct names such as `T3_design`, `T3_continuous_limit`, `T3_transient_limit`, and `T3_trip_limit`. A design temperature is not automatically a protection boundary.

## Application Branches

Power-generation models often need:

- Generator or load model.
- Power turbine or shaft speed/frequency behavior.
- Grid-connected versus islanded control distinction.
- Fuel limits, acceleration limits, turbine inlet temperature limits, and load rejection behavior.

Propulsion models often need:

- Thrust or propulsor load relation.
- Spool speed control or fuel scheduling.
- Surge margin, acceleration schedule, turbine temperature limit, and altitude/Mach corrections if relevant.
- Nozzle, fan, propeller, or aircraft operating condition model when required.

Mechanical-drive models often need:

- Driven machine torque or power curve.
- Shaft speed or load control.
- Load inertia and transient torque behavior.

If the application is unclear, stop at a scoping plan and ask the user to confirm the intended branch.

## Reduced Versus Validated Model

If formulas, maps, geometry, fuel data, or validation data are missing, mark the model as one of:

- `exploratory`: useful for structure and workflow, not validated.
- `reduced`: intentionally omits physical effects with known limitations.
- `design-point checked`: compared against a design-point or steady reference only.
- `dynamic-initialization checked`: dynamic states initialize near a design or trim point and derivatives/residuals are reported.
- `calibrated/externally validated`: compared against experiment, manufacturer data, benchmark data, or an explicitly trusted external reference.

Do not label a model validated only because it runs.
