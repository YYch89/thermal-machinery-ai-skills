# Dynamic Initialization

Use this file before adding dynamic states or judging a dynamic model.

## Dynamic State Registry

Create an initial-condition registry for:

- volume pressures and masses;
- thermal capacities and wall temperatures;
- rotor speeds and shaft inertias;
- species inventories;
- actuator states;
- controller states;
- delays, memories, transport delays, unit delays, transfer functions, and integrators;
- lookup-table schedules and normalization constants.

## Mapping Rule

Each dynamic initial condition must map back to:

- a ledger row;
- a state-point value;
- a trim calculation;
- a project data source;
- or an explicitly declared assumption.

Same-name variables are not enough. Match node, stream, unit, basis, and physical meaning.

## Validation

At the intended initial operating point:

- mass and energy residuals should be near zero for steady states;
- pressure and flow derivatives should be near zero for volumes;
- shaft acceleration should be near zero for steady shaft speeds;
- thermal state derivatives should be near zero unless a transient warm-up is intended;
- controller action should not be required to pull an untrimmed plant back to the operating point.
