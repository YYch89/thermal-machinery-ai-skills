# Skill Validation Tasks

Use this file to test whether an AI agent follows `thermal-machinery-dynamic-modeling`.

## Task 1: From-Scratch Workflow

Prompt:

```text
Build a first-pass dynamic modeling workflow for a thermal power system with a compressor, combustor, turbine, recuperator, and load. I know the target power and turbine inlet temperature, but not the full topology or component data.
```

Expected behavior:

- Ask for or list missing boundary, fluid, topology, and fidelity decisions.
- Create or request a depth and simplification contract.
- Build topology and node ledger before equations.
- Define component contracts and guessed states.
- Mark missing maps, heat-transfer data, pressure losses, and validation data.
- Refuse to jump directly to a dynamic simulation.

## Task 1B: Fidelity Triage

Prompt:

```text
Build whatever level of model is reasonable for a thermal system with a heat source, heat exchanger, turbine, and load. I am not sure whether I need a design-point model or full dynamics.
```

Expected behavior:

- Ask for or state the model-depth options.
- Choose the lowest useful stage when the user delegates.
- Separate design-point, steady, reduced dynamic, and detailed dynamic claims.
- State allowed simplifications and forbidden claims.

## Task 2: Node Ledger Challenge

Prompt:

```text
Create a node-by-node ledger for a heat-recovery system where exhaust heats a fuel stream and a steam stream before entering a turbine.
```

Expected behavior:

- Separate exhaust, fuel, and steam streams.
- Create hot/cold inlet and outlet rows for each heat exchanger.
- Record temperature, pressure, flow, composition or phase quality, units, source, and calculation status.
- Mark guessed outlet or inlet states and closing residuals.

## Task 3: Dynamic Initial Condition Challenge

Prompt:

```text
My dynamic model runs but drifts immediately from the design point. How should I audit initialization?
```

Expected behavior:

- Build a design-to-dynamic map.
- Audit volumes, rotors, thermal capacities, integrators, delays, memories, transfer functions, and lookup schedules.
- Check derivatives or residuals at the initial point.
- Separate plant trim problems from controller tuning.

## Failure Map

| Failure observed | Reference to improve |
| --- | --- |
| Starts with code instead of topology or depth contract | `workflow-and-scope.md` |
| Mixes streams or units | `thermodynamic-node-stream-ledger.md` |
| Component has no clear inputs or residuals | `component-contracts.md` |
| Dynamic model drifts from design point | `dynamic-initialization.md` |
| Claims completion from run success alone | `validation-and-deliverables.md` |
| Reuses control assumptions without physical authority | `component-contracts.md` and `workflow-and-scope.md` |
