# Control Integration

## Purpose

Control should be added after the open-loop plant is physically initialized and validated. Do not use a controller to hide plant-model errors.

## Application-Dependent Control Targets

Choose control structure from the application:

For more detailed application branches and controller integration sequence, use `control-application-patterns.md`.

| Application | Common control objective | Typical controlled or limited variables |
| --- | --- | --- |
| Islanded power generation | Power turbine/generator speed or frequency | Fuel flow, load, turbine inlet temperature, acceleration |
| Grid-connected power generation | Power output, fuel schedule, load sharing, temperature limits | Generator power, fuel valve, turbine inlet temperature, speed protection |
| Propulsion | Thrust, spool speed, acceleration schedule | Fuel flow, nozzle/propulsor variables, surge margin, turbine temperature |
| Mechanical drive | Driven-load speed or torque | Fuel flow, shaft speed, load torque, temperature limit |

Ask the user to confirm the application branch before adding a controller.

## Plant Before Controller

Before adding control:

- The design-point model should match its MATLAB or reference result.
- The steady-state model should reproduce the rated point.
- Dynamic rotor and volume initial derivatives should be within declared tolerances.
- Characteristic maps should be inside valid ranges at the initial point.
- Fuel and load inputs should be available as plant inputs.

If the open-loop plant cannot hold rated initialization, fix the plant or initial conditions before tuning the controller.

Do not tune a controller to hide:

- nonzero rated rotor power residuals;
- nonzero volume flow residuals;
- combustor mass or energy imbalance;
- invalid compressor or turbine map operation;
- unit-conversion mistakes;
- slow drift visible only in longer simulation;
- incorrect fuel, load, or actuator initial conditions.

If closing the loop makes an invalid plant appear stable, report the plant issue first and keep the controller result exploratory.

## Controller Evidence

For each controller, document:

- Controlled variable.
- Manipulated variable.
- Sensor or measured signal.
- Actuator dynamics and limits.
- Reference command or schedule.
- Saturation, rate limit, and anti-windup behavior if used.
- Tuning method or source.
- Validation scenario such as load step, fuel step, speed command, or thrust command.

## Common Generator Control Notes

For free power turbine generation, the power turbine or generator speed often maps to electrical frequency. In an islanded case, speed/frequency control may be central. In a grid-connected case, the grid can constrain speed, and power/fuel/load control may be more important.

Do not assume one control law covers both cases.

## Common Propulsion Control Notes

Propulsion models may require thrust or propulsor-load modeling rather than generator speed control. Surge margin and turbine temperature limits are often as important as speed tracking.

Do not reuse generator-speed control without confirming the propulsion architecture and controlled variable.
