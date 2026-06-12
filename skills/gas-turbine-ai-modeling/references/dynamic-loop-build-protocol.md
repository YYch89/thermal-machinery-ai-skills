# Dynamic Loop Build Protocol

## Purpose

Build dynamic gas turbine models by closing one feedback loop at a time. A full three-shaft dynamic model contains several nested loops. Connecting all of them at once makes errors hard to locate and often creates hidden algebraic loops or untraceable initial conditions.

Use this protocol after the design-point and steady-state models reproduce rated conditions.

## Preconditions

Before adding dynamic loops, prepare:

- Design-point state table.
- Steady-state model that reproduces the design point at rated air and fuel flow.
- Dynamic iteration map.
- Initial-condition registry.
- Characteristic-map source and fitting evidence.
- Solver and sample-time choice.

If any item is missing, either create it or mark the dynamic model as exploratory rather than validated.

## Loop Contract

For each dynamic loop, document this contract before editing Simulink:

| Field | Meaning |
| --- | --- |
| Loop name | Low-pressure shaft, high-pressure shaft, power shaft, combustor, or volume |
| State variable | Speed, pressure, temperature, actuator position, or other state |
| State equation | Formula or block expression used for derivative or update |
| Inputs | Signals entering the state equation |
| Outputs | Signals produced by the state |
| Feedback destination | Map, pressure-ratio calculation, expansion-ratio calculation, load, or controller |
| Initial value | Value and source |
| Zero-derivative check | Condition expected at design-point initialization |
| Isolation test | Temporary test that verifies only this loop |

Do not implement a feedback loop without this contract.

## Recommended Build Order

1. Keep the steady thermodynamic chain fixed and expose all component works and flows.
2. Add compressor map wrappers while holding pressures and speeds at design-point values.
3. Add turbine map wrappers while holding pressures and speeds at design-point values.
4. Add the first compressor-side volume pressure state and verify `dP/dt` is near zero at the design point.
5. Add turbine-side volume pressure states one at a time and verify each pressure derivative.
6. Add low-pressure and high-pressure rotor states one at a time and verify rotor acceleration is near zero.
7. Add power-shaft dynamics and load only after turbine work is credible.
8. Add combustor temperature or pressure dynamics only after air and gas flow continuity is credible.
9. Add fuel actuator, IGV, load schedule, and controller modules after the plant initializes correctly.

The exact order can change if the existing model requires it, but do not close a new loop until the previous loop has a design-point check.

## Isolation Tests

Use simple isolation tests before full transient simulations:

- Replace a map output with the design-point value and verify downstream equations.
- Hold shaft speed constant and verify volume pressure states.
- Hold volume pressures constant and verify rotor work balance.
- Hold fuel flow constant and verify combustor energy balance.
- Disconnect controller action and run plant-only initialization.

Remove or clearly label temporary test blocks after the check. Do not leave hidden constants that bypass the real feedback path.

## Algebraic-Loop Handling

Use `Memory`, `Unit Delay`, or discrete integrators only where a feedback path is physically or numerically justified.

For each loop-breaking block:

- Record the state or signal it represents.
- Set an explicit initial value.
- Use the design-point or steady-state value when available.
- Confirm the introduced delay does not change the intended physical meaning.
- Check whether inherited sample time is appropriate.

A delay used only to silence an algebraic-loop warning must still be documented and validated.

Selection guidance:

- Use an `Integrator` or `Discrete-Time Integrator` for a physical state such as shaft speed, pressure, or temperature.
- Use `Memory` for a block-level algebraic-loop break when the intended behavior is same-step feedback with an initialization value.
- Use `Unit Delay` when the loop is intentionally discrete and one sample of delay is acceptable.
- Use `Transport Delay` or `Transfer Fcn` only for an actuator, sensor, fuel system, load, or empirical lag with documented time constant or delay.

Do not convert a physical continuous feedback path into a discrete delay without stating the sample time and expected effect on transient response.

## Design-Point Initialization Check

At the rated initial point:

- Compressor and turbine map outputs should match design flows after correction.
- Volume derivatives should be close to zero.
- Rotor accelerations should be close to zero.
- Combustor temperature derivative should be close to zero if combustor thermal dynamics are present.
- Saturation blocks should not be active unless the design point is intentionally on a limit.
- The model should not need controller action to hold a nominal plant equilibrium.

If this check fails, fix the loop or initial condition before testing transients.

## Transient Readiness

Only run fuel steps, load steps, IGV movement, or controller tests after the plant passes initialization. When transient behavior is tested, record:

- Input schedule.
- Solver settings.
- Initial-condition set.
- Peak turbine inlet temperature.
- Shaft-speed response.
- Pressure response in each volume.
- Surge or map-range margin.
- Final steady state or reason for non-convergence.
