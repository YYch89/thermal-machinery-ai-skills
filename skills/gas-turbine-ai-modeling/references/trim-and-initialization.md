# Trim and Initialization

## Purpose

Design-point values are a starting point, not always a consistent dynamic initial condition. After adding maps, volumes, actuator states, or controllers, trim the model or solve for a consistent initial operating point.

## When Trim Is Needed

Trim or steady initialization is needed when:

- Map outputs do not match design-point flows at the initial pressure ratios and speeds.
- Volume pressure derivatives are not close to zero.
- Rotor accelerations are not close to zero.
- Combustor temperature or pressure derivative is not close to zero.
- Actuator, fuel system, or controller states start away from their rated values.
- Saturation is active at nominal rated operation without justification.

## Earlier Failure After Correcting Equations

If a model fails earlier after replacing a suspect equation with the physically intended form, do not assume the correction is wrong. The old structure may have been masking an initial residual.

For example, changing a volume pressure module from a double-integrated flow-mismatch structure to `dP/dt = R*T*(m_in - m_out)/V` may expose inconsistent initial flows, pressure ratios, map outputs, or Memory/Delay states. In this situation, keep the corrected equation under review, then run the initialization workflow below. Revert only if the corrected equation has a source, unit, sign, or control-volume error.

## Initialization Workflow

1. Start from the design-point state table.
2. Convert design values to model units.
3. Populate the initial-condition registry.
4. Hold controller action fixed or disable controller if validating the plant.
5. Evaluate map outputs at design speed and pressure or expansion ratios.
6. Compute residuals for flow, power, pressure, and combustor energy.
7. Adjust only the intended trim variables, not arbitrary hidden constants.
8. Record the final trim point and residuals.
9. Use the trim point as dynamic initial condition.

## Possible Trim Variables

Choose trim variables according to the model:

- Fuel flow.
- Shaft speeds.
- Inter-component pressures.
- Turbine inlet temperature.
- Map operating points.
- Load power or torque.
- Actuator initial states.

Do not tune all variables freely. Each trim variable should have a physical reason.

## Residual Table

Use a table like this:

| Residual | Formula or signal | Target | Tolerance | Result |
| --- | --- | --- | --- | --- |
| Low shaft balance | turbine power - compressor power | 0 | declared |  |
| High shaft balance | turbine power - compressor power | 0 | declared |  |
| Power shaft balance | power turbine power - load power | 0 | declared |  |
| Compressor volume | inlet flow - outlet flow | 0 | declared |  |
| Turbine volume | inlet flow - outlet flow | 0 | declared |  |
| Combustor energy | energy in - energy out | 0 | declared |  |
| Map consistency | map output - thermodynamic requirement | 0 | declared |  |

## Simulink Practice

Use MATLAB/Simulink tools when available:

- Read model structure and parameters before trimming.
- Resolve workspace variables used by initial conditions.
- Use Simulink trim, operating point, or scripted steady solve only when the model equations and inputs are understood.
- After trimming, write results back to an explicit initial-condition registry.

Do not accept a trim result that violates component map ranges or physical bounds.

## Controller Initialization

For closed-loop models:

- Initialize actuator and controller states to match the plant trim point.
- Confirm controller output equals rated fuel, guide vane, load, or command value.
- Check anti-windup and saturation states.
- Validate open-loop plant before interpreting closed-loop transient quality.
