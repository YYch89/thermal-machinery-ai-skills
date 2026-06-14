# Workflow And Scope

Use this file when starting a thermal-machinery dynamic modeling task.

## Intake

Record:

- application: power generation, propulsion, refrigeration, heat pump, process heat, hybrid power, storage, or test rig;
- working fluids and composition assumptions;
- system boundary and environment interactions;
- required model depth: design point, steady state, dynamic plant, controller, optimization, or fault simulation;
- fidelity target and allowed simplifications: concept, design point, executable design reproduction, steady plant, reduced dynamic plant, detailed dynamic plant, or controlled/optimized plant;
- available evidence: equations, drawings, data sheets, maps, code, Simulink models, experiments, or literature;
- target outputs: power, thrust, heat rate, COP, efficiency, pressure, temperature, flow, emissions, speed, load, or safety limits.

## Staged Build

1. Define scope and boundary.
2. Create a depth and simplification contract.
3. Draw or describe the topology as a directed stream graph.
4. Check heat grade, pressure compatibility, working-media availability, and actuator authority.
5. Create the node and stream ledger.
6. Define component contracts.
7. Solve a design or steady state.
8. Check balances and constraints.
9. Map steady values to dynamic initial conditions.
10. Add physical dynamic states.
11. Add control after the open-loop plant initializes and the actuator authority is clear.
12. Validate and report unresolved assumptions.

## Stop Conditions

Stop and ask or mark the model incomplete when:

- working fluid or composition is unknown;
- topology is ambiguous;
- required model depth or simplification level is ambiguous;
- a component has unknown inlet or outlet state and no residual is defined;
- pressure units or flow basis are ambiguous;
- dynamic rate constants, maps, heat-transfer coefficients, or volumes are required but unavailable;
- a control variable has no physical actuator or storage path in the selected topology;
- simulation success is used as proof without balance and initialization checks.
