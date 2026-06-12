# Stage Gates and User Confirmation

## Purpose

Gas turbine models should be built in auditable stages. Each major stage changes the meaning of the model. Ask the user to confirm important artifacts before proceeding to the next stage.

## Confirmation Gates

Use these gates unless the user explicitly requests a fully autonomous exploratory draft:

| Gate | User confirms |
| --- | --- |
| Scope gate | Application, architecture, working-fluid assumptions, dynamic depth, and control objective |
| Theory gate | Selected formulas, literature sources, map conventions, and assumptions |
| Design-point gate | State table, air/fuel flow, component works, efficiencies, cooling/bleed coefficients |
| Design-point Simulink gate | Simulink design-point outputs match MATLAB/reference outputs within tolerance |
| Steady-state gate | Rated air/fuel input reproduces design point and output variables are physically consistent |
| Dynamic iteration gate | Dynamic iteration map, loop contracts, and initial-condition registry are complete |
| Dynamic initialization gate | Rotor accelerations, pressure derivatives, combustor residuals, and map ranges pass declared tolerances |
| Control gate | Control objective, controlled variable, actuator, limits, and validation scenarios are confirmed |

## How To Ask

At a gate, present:

- Artifact path or table.
- Key numerical results.
- Declared tolerances.
- Differences from the previous stage.
- Assumptions or unresolved items.
- One clear question asking whether to proceed, revise, or investigate.

Do not ask the user to approve a vague model. Ask them to approve specific evidence.

## When User Confirmation Is Not Available

If the task requires autonomous progress and the user is not available:

- Continue only with low-risk audit, drafting, or exploratory model work.
- Mark unconfirmed choices as assumptions.
- Do not label later stages validated.
- Leave a list of confirmation items for the user.
