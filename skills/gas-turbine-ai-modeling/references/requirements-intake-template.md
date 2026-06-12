# Requirements Intake Template

## Purpose

Use this template at the start of a gas turbine modeling task when the user has not fully specified the application, architecture, working fluid, data sources, or expected deliverable.

The goal is to prevent hidden assumptions. Do not assume the default three-shaft generation reference case unless the user confirms it.

## Intake Table

Fill this table from the user prompt, provided files, or follow-up answers:

| Area | Required content | Status |
| --- | --- | --- |
| Application | Power generation, propulsion, mechanical drive, hybrid system, test rig, or education |  |
| Operating context | Grid-connected, islanded, shipboard DC microgrid, propulsor/nozzle, pump/compressor load, or other |  |
| Architecture | Single-shaft, two-shaft, three-shaft, free power turbine, recuperated, intercooled, reheated, hybrid, or other |  |
| Shaft coupling | Which turbine drives which compressor or load |  |
| Rated target | Power, thrust, shaft speed, pressure ratio, turbine inlet or combustor outlet temperature |  |
| Ambient condition | Inlet pressure, inlet temperature, humidity, altitude, Mach number if relevant |  |
| Fuel | Fuel type, LHV, combustion efficiency, composition if needed |  |
| Working fluid | Constant cp/gamma, variable heat capacity, combustion products, humidity, cooling/mixing |  |
| Component data | Efficiencies, pressure losses, cooling/bleed, maps, geometry, volume estimates, inertias |  |
| Available evidence | User MATLAB code, Simulink model, map data, textbook, paper, test data, open-source reference |  |
| Dynamic depth | Rotor speed, volume pressure, combustor temperature/pressure, actuator, sensors, controller |  |
| Control objective | Speed, frequency, power, thrust, fuel schedule, turbine temperature, surge margin, load following |  |
| Deliverable target | Design-point solver, Simulink design-point model, steady plant, dynamic plant, repair, review, or control model |  |
| Validation target | Design-point match, long simulation, scenario matrix, experimental comparison, or teaching demonstration |  |

Use `known`, `missing`, `assumed`, or `not applicable` in the Status column.

## Minimum Follow-Up Rule

If the user wants the agent to start modeling and a critical field is missing, ask the smallest question that unlocks the next stage.

Critical missing fields usually include:

- Application branch.
- Architecture and shaft coupling.
- Fuel or property model.
- Rated power/thrust/speed and key design limits.
- Whether the deliverable is design point, steady, dynamic, control, repair, or review.
- Whether maps or validation data are available.

If the user asks for a read-only plan, list the missing items and do not block on answers.

## Modeling Mode Decision

After intake, classify the task:

| Mode | Use when | Next reference |
| --- | --- | --- |
| New model from zero | User wants a new model and provides or accepts assumptions | `three-shaft-workflow.md`, `design-point-solver.md` |
| Existing model audit | User provides `.m`, `.slx`, maps, or results and asks whether they are correct | `model-evidence-audit.md` |
| Existing model repair | Model fails, drifts, produces `NaN`/`Inf`, or has nonphysical states | `existing-model-debug-and-repair.md` |
| Formula research | Equations, fuel properties, maps, or applicability are missing | `literature-and-formula-evidence.md` |
| Controller integration | Plant exists and user asks for speed, power, thrust, or fuel control | `control-integration.md`, `control-application-patterns.md` |
| Deliverable packaging | User asks whether the model is complete or ready to share | `deliverable-definition.md`, `modeling-output-templates.md` |

## Assumption Statement

Before coding or editing, write a short statement:

```text
Task goal:
Known facts:
Necessary assumptions:
Blocked or missing items:
Verification standard:
Next stage gate:
```

Do not hide an assumption by embedding it only in code, a workspace variable, or a Simulink block parameter.
