# Workflow And Scope

Use this file when starting a thermal-machinery dynamic modeling task.

## Intake

Record:

- application: power generation, propulsion, refrigeration, heat pump, process heat, hybrid power, storage, or test rig;
- working fluids and composition assumptions;
- system boundary and environment interactions;
- required model depth: design point, steady state, dynamic plant, controller, optimization, or fault simulation;
- available evidence: equations, drawings, data sheets, maps, code, Simulink models, experiments, or literature;
- target outputs: power, thrust, heat rate, COP, efficiency, pressure, temperature, flow, emissions, speed, load, or safety limits.

## Staged Build

1. Define scope and boundary.
2. Draw or describe the topology as a directed stream graph.
3. Create the node and stream ledger.
4. Define component contracts.
5. Solve a design or steady state.
6. Check balances and constraints.
7. Map steady values to dynamic initial conditions.
8. Add physical dynamic states.
9. Add control after the open-loop plant initializes.
10. Validate and report unresolved assumptions.

## Stop Conditions

Stop and ask or mark the model incomplete when:

- working fluid or composition is unknown;
- topology is ambiguous;
- a component has unknown inlet or outlet state and no residual is defined;
- pressure units or flow basis are ambiguous;
- dynamic rate constants, maps, heat-transfer coefficients, or volumes are required but unavailable;
- simulation success is used as proof without balance and initialization checks.
