# Case Library

## Purpose

Use these compact cases as pattern examples. They are not universal formulas or validation data. They show how the skill expects an agent to reason, stage work, and report evidence.

## Case 1: Three-Shaft Model From Design Point To Dynamics

Task:

- Build a staged model for a three-shaft gas turbine with low-pressure compressor, high-pressure compressor, combustor, high-pressure turbine, low-pressure turbine, power turbine, bleed/cooling, rotor dynamics, volume dynamics, and characteristic maps.

Key risks:

- Treating the design-point solver as the dynamic model.
- Closing compressor maps, turbine maps, volumes, and rotors all at once.
- Missing design-point-to-dynamic initial-condition mapping.

Correct route:

1. Build the design-point MATLAB solver and state table.
2. Convert the design-point equations to Simulink and compare state points.
3. Convert to a steady input-output thermodynamic plant.
4. Add maps and dynamic loops one by one.
5. Register every shaft, volume, combustor, fuel, map, Memory, and Delay initial value.
6. Add control only after open-loop plant residuals pass.

Validation:

- Design-point MATLAB versus Simulink comparison.
- Rated steady reproduction.
- `dN/dt`, `dP/dt`, and combustor residuals near zero at rated initialization.
- Long simulation without slow drift or invalid map operation.

## Case 2: Two-Shaft Free Power Turbine Generator

Task:

- Build a reduced dynamic model for a two-shaft free power turbine gas turbine used for isolated generation, such as a shipboard DC microgrid study.

Key risks:

- Assuming single-shaft power balance.
- Treating equivalent load torque as a full electrical system.
- Tuning PT speed control before the gas-generator plant is initialized.

Correct route:

1. Confirm whether the electrical system is equivalent load, generator only, or generator-converter-DC bus.
2. Build design point for gas generator and power turbine separately.
3. Use characteristic maps or documented reduced flow laws for compressor and turbines.
4. Validate gas-generator rotor and PT rotor power residuals before closing speed control.
5. Add PT speed or generator-frequency control only after plant validation.

Validation:

- Rated PT speed and load torque match rated power.
- Load step does not drive pressure, temperature, flow, shaft speed, or map validity outside declared bounds.
- Long hold shows no hidden drift.

## Case 3: Existing Dynamic Model NaN/Inf Repair

Task:

- Repair an existing gas turbine Simulink model that fails at a downstream shaft integrator.

Key risks:

- Adding saturation to the reported integrator instead of tracing the upstream physical cause.
- Ignoring volume pressure equations and Memory/Delay initial values.
- Claiming repair after a short simulation only.

Correct route:

1. Reproduce original failure time and reported block.
2. Log the first nonphysical pressure, temperature, flow, speed, or map-valid signal.
3. Trace two to four signal layers upstream.
4. Inspect volume pressure dynamics for the instantaneous `m_in - m_out` relation.
5. Audit Memory, Delay, Unit Delay, Integrator, and Transfer Fcn initial values.
6. Test a temporary fix, then save a fixed copy only after evidence supports it.

Validation:

- Simulation passes the original failure time.
- Staged duration ladder passes: `0.01 s -> 1 s -> 10 s -> 50 s -> long run`.
- Final-window drift, `NaN`/`Inf`, and nonphysical-state checks are reported.

## Case 4: Scattered Compressor Map To Lookup Table

Task:

- Convert scattered compressor or turbine map data into a Simulink lookup-table implementation.

Key risks:

- Filling a rectangular table by nearest neighbor and treating the full rectangle as physically valid.
- Losing normalization constants or corrected-flow definitions.
- Failing to track transient operation outside the map domain.

Correct route:

1. Identify whether the map is regular grid, scattered points, speed lines, polynomial fit, or neural network.
2. Preserve raw source data and normalization definitions.
3. Create interpolation output separately from valid-domain logic.
4. Use a convex hull, speed-line envelope, alpha shape, or `valid_table` equivalent.
5. Check design point, steady points, transient path, and long-run final window against the valid domain.

Validation:

- Rated point is inside the valid domain.
- Fit or interpolation error is reported near the design point and over the usable range.
- `map_valid` or equivalent validity signal is logged during dynamic runs.

## Case 5: Controller Hides Plant Drift

Task:

- A dynamic gas turbine appears stable after adding a controller, but the open-loop rated plant drifts in pressure or shaft speed.

Key risks:

- Mistaking closed-loop compensation for a physically valid plant.
- Tuning fuel control to cancel map, volume, or rotor residuals.
- Ignoring actuator and controller initial states.

Correct route:

1. Disable or hold controller action and verify open-loop rated initialization.
2. Check rotor power residuals, volume flow residuals, combustor residuals, and map consistency.
3. Trim the plant or correct initial conditions before tuning.
4. Initialize controller and actuator states to match rated manipulated variables.
5. Re-run closed-loop scenarios after plant residuals pass.

Validation:

- Open-loop plant residuals are within declared tolerances.
- Controller output equals rated fuel, load, or geometry command at initialization.
- Load or command transients remain inside map and protection limits.
