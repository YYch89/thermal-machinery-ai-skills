# Control Application Patterns

## Purpose

Use this reference when adding or reviewing gas turbine control. Control structure must follow the application branch and plant maturity. Do not use one generator speed controller as the default for all gas turbines.

## Control Preconditions

Before adding control, confirm:

- The plant application branch is known.
- The gas turbine architecture and shaft coupling are known.
- The open-loop plant has a rated initial condition with rotor and volume residuals within declared tolerances.
- Characteristic map operating points are inside valid ranges.
- Fuel, actuator, load, and sensor initial states are registered.
- The user has accepted the model maturity level.

If these are false, keep control exploratory and report the plant limitation first.

## Application Branch Table

| Application | Primary boundary condition | Common controlled variable | Common manipulated variable | Important limits |
| --- | --- | --- | --- | --- |
| Islanded generator | Load varies, generator speed sets frequency | Power turbine/generator speed or frequency | Fuel flow, sometimes load dump or guide vane | Fuel rate, acceleration, turbine temperature, overspeed |
| Grid-connected generator | Grid fixes frequency or strongly constrains speed | Power output, fuel schedule, load sharing | Fuel flow, generator torque/power command | Turbine temperature, emissions, ramp rate, surge margin |
| Shipboard DC microgrid | Electrical load and DC bus dynamics may vary | PT speed, generator power, or DC bus voltage through generator interface | Fuel flow, generator torque, converter command | Speed, fuel rate, TIT/EGT, bus voltage, load step |
| Mechanical drive | Driven machine torque curve dominates | Driven shaft speed, load torque, or process variable | Fuel flow, guide vane, load valve | Shaft torque, speed, temperature, surge margin |
| Propulsion | Flight/ship operating point and propulsor/nozzle matter | Thrust, spool speed, propeller speed, or fuel schedule | Fuel flow, nozzle/propulsor/variable geometry | Surge margin, turbine temperature, acceleration, altitude/Mach envelope |
| Test rig or teaching model | User-defined perturbation | Usually one state or output for demonstration | Fuel, air flow, load, speed command | Keep assumptions visible |

## Generator Control Notes

For islanded generation, PT or generator speed control is often appropriate because speed maps to frequency. Use plant residual checks before tuning the speed loop.

For grid-connected generation, speed may be constrained by the grid, so power or fuel scheduling may be the central control objective. Do not force a free PT speed loop unless the generator/grid model supports it.

For shipboard DC microgrid studies, decide whether the gas turbine model includes:

- Only an equivalent load torque or load power.
- A generator model.
- A rectifier or converter.
- A DC bus capacitor and bus-voltage controller.

If the electrical subsystem is omitted, label the load as equivalent and do not claim DC bus voltage behavior.

## Propulsion Control Notes

Propulsion models may require thrust, nozzle, fan, propeller, flight condition, or ship propulsor coupling. Speed control alone may not represent the objective.

Before building propulsion control, clarify:

- Aircraft, marine, or generic propulsion use.
- Propulsor/nozzle model and operating condition.
- Whether thrust is modeled directly or inferred from flow and exhaust state.
- Surge-margin and turbine-temperature limiting.
- Acceleration/deceleration fuel schedule.

Do not reuse generator PT-speed control unless the user explicitly wants a reduced propulsion demonstration.

## Limiter And Protection Layer

Separate the primary controller from limiters:

| Limiter | Purpose | Evidence required |
| --- | --- | --- |
| Fuel minimum/maximum | Keep fuel within actuator or combustion bounds | physical or assumed fuel bounds |
| Fuel rate limit | Prevent unrealistically fast fuel changes | actuator or schedule assumption |
| Acceleration limit | Protect rotor and map stability | shaft-speed derivative check |
| Temperature limit | Protect turbine or combustor | distinguish design, continuous, transient, and trip limits |
| Surge margin limit | Avoid compressor instability | map surge line or validity proxy |
| Overspeed trip | Protect shaft/load | speed threshold and action |

Limiters should not hide invalid plant initialization. Record whether any limiter is active at the rated point.

## Controller Integration Sequence

1. Validate open-loop rated initialization.
2. Add actuator dynamics with initial state equal to rated manipulated variable.
3. Add sensor or measurement path if needed.
4. Add primary controller with disabled or wide limiters for first polarity checks.
5. Verify controller sign using a small command or load perturbation.
6. Add rate limits, temperature limits, surge limits, and overspeed protection.
7. Run scenario matrix and long-hold checks.

If the controller stabilizes an otherwise drifting plant, stop and report the plant residual.

## Minimum Control Report

| Field | Content |
| --- | --- |
| Application branch |  |
| Controlled variable |  |
| Manipulated variable |  |
| Plant validation before control |  |
| Actuator and sensor dynamics |  |
| Controller structure | PID, schedule, state feedback, custom logic, etc. |
| Limits and protections |  |
| Initial controller output | Should match rated fuel/load/geometry command |
| Validation scenarios | Load step, speed command, fuel step, thrust command, long hold |
| Open issues |  |
