# Simulink Staging

## Design-Point Simulink Model

The first Simulink version should reproduce the MATLAB design-point calculation, not add dynamic behavior. Use it to verify formula transfer, subsystem interfaces, and bus contents.

Recommended top-level subsystems:

- `Compressor_Low`
- `Compressor_High`
- `Combustion chamber`
- `Turbine_High`
- `Turbine_Low`
- `Turbine_Power`
- Volume or pressure-loss modules where needed

Each subsystem should expose pressure, temperature, flow information, and work output/consumption.

## MATLAB-to-Simulink Iteration

MATLAB design-point code may use explicit loops. Simulink usually needs feedback:

- Use feedback paths for heat capacity, adiabatic exponent, excess-air coefficient, cooling flow coefficient, or flow coefficient iteration.
- Add `Memory` or `Unit Delay` where a direct algebraic loop would occur.
- Use reliable design-point initial values.
- Expose iteration outputs or convergence indicators when possible.

Do not hide numerical iteration inside an opaque block unless the user specifically wants a MATLAB Function implementation.

## Wrapper Versus Component Plant

A Simulink wrapper around MATLAB plant equations is useful for V1 validation, but it is not the same as a final component-level Simulink plant.

For V0/V1:

- MATLAB functions, MATLAB Function blocks, Fcn blocks, or Interpreted MATLAB Function blocks may be used to test equations quickly.
- Label the result as a baseline or wrapper validation platform.
- Compare it against the design-point solver and residual checks.

For V2+ component-level delivery:

- Core plant physics should be visible in Simulink component subsystems.
- Prefer primitive arithmetic blocks, lookup tables with validity logic, explicit integrators, explicit delays, and named signals.
- Do not hide compressor, combustor, turbine, volume, rotor, fuel-actuator, or load equations inside a single opaque block unless the user approves and the component is marked partially opaque.
- MATLAB scripts may still be used to generate the model or compute reference values.

See `model-maturity-and-delivery.md` before claiming that a Simulink plant is complete.

## Transition to Steady-State Model

The steady-state thermodynamic model is not the same as the design-point model.

Design-point model:

- Input: design requirements.
- Output: rated state table, rated flow, fuel flow, and component powers.

Steady-state model:

- Input: air flow, fuel flow, shaft speed or pressure ratio assumptions, component efficiencies, pressure losses, cooling parameters.
- Output: actual turbine inlet temperature, powers, pressures, temperatures, and fuel consumption response.

When converting to steady-state:

1. Replace rated power as a design input with actual air and fuel flow inputs.
2. Preserve design pressure ratios or map-based pressure ratios only if justified.
3. Keep cooling and bleed flows consistent with combustor and turbine mass balances.
4. Recompute actual output power from component work.
5. Verify the rated input case reproduces the design point.

Create a design-point to steady/dynamic mapping table before this conversion. Include reference flows, fuel flow, pressure ratios, efficiencies, state pressures, state temperatures, shaft speeds, cooling coefficients, and map normalization constants. See `deliverable-definition.md`.

For off-design steady-state models, identify the matching residuals instead of carrying fixed design pressure ratios into the plant. See `off-design-matching.md`.

## Bus and Signal Rules

Use buses to pass grouped thermodynamic information only when the bus contents are documented. Typical bus contents include:

- Compressor temperature rise.
- Heat capacity.
- Air flow.
- Fuel-air ratio.
- Gas constant.
- Cooling flow coefficients.
- Turbine flow coefficients.

For AI-generated models, prefer clear signal names over anonymous `From`/`Goto` networks. If the existing model uses `Goto`/`From`, list the important tags and their meanings before editing.

## Existing Model Audit

Before editing an existing Simulink model, collect executable evidence rather than relying on layout:

- Main subsystem hierarchy and interfaces.
- Important cross-subsystem connections.
- Dynamic blocks and their initial conditions.
- `Goto`/`From` tags that carry pressure, temperature, flow, work, speed, fuel, or map signals.
- Workspace variables used by constants, gains, maps, and state blocks.
- Saturation, delay, or transfer-function blocks that can change transient behavior.

For large dynamic models, use `model-evidence-audit.md` before changing blocks.

## Solver and Sample-Time Awareness

For dynamic models, record solver settings, stop time, fixed step, and discrete sample times. If using discrete integrators, document their initial conditions and relation to design-point values.
