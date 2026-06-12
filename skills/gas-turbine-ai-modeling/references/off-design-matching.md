# Off-Design Matching

## Purpose

Off-design and dynamic gas turbine models require component matching. A design-point calculation can prescribe pressure ratios and flows; an off-design plant must solve the coupling among maps, shaft speeds, pressure ratios, volume pressures, fuel flow, and load.

## Matching Variables

Common matching variables include:

- Compressor corrected speed, corrected flow, pressure ratio, and efficiency.
- Turbine corrected speed, corrected flow, expansion ratio, and efficiency.
- Shaft speeds.
- Inter-component pressures.
- Combustor pressure and turbine inlet temperature.
- Fuel flow.
- Load or thrust boundary.

State which variables are prescribed, which are solved, and which are returned by maps.

## Design-Point Versus Off-Design

Design-point model:

- Often prescribes pressure ratios, efficiencies, and turbine inlet temperature.
- Solves air flow and fuel flow from rated power and thermodynamic balances.

Off-design steady model:

- Uses fuel flow, ambient condition, shaft speed or load, and maps.
- Solves matching pressure ratios, flows, temperatures, and output power.

Dynamic model:

- Uses state equations for speeds, pressures, and thermal states.
- Map outputs and volume/shaft states create the matching process over time.

Do not carry design-point pressure ratios into off-design as fixed values unless the model is explicitly reduced.

## Map Direction

Document the map direction:

- Forward map: inputs are corrected speed and pressure ratio; outputs are corrected flow and efficiency.
- Inverse map: inputs may include corrected speed and corrected flow; output is pressure ratio or expansion ratio.
- Interpolated table: specify axes and extrapolation rules.
- Neural-network map: specify feature vector, target, normalization, and valid region.

If the available map direction does not match the dynamic loop, add a documented solver, inverse fit, or residual equation rather than swapping variables silently.

## Residuals for Steady Matching

A steady off-design solve may use residuals such as:

```text
compressor_flow - downstream_flow = 0
turbine_flow - downstream_flow = 0
turbine_power - compressor_power - load_power = 0
combustor_energy_residual = 0
map_pressure_ratio - thermodynamic_pressure_ratio = 0
```

For each residual, record the variable solved and the tolerance.

## Dynamic Matching Through States

In a dynamic model, residuals become state derivatives:

- Flow mismatch changes volume pressure.
- Power mismatch changes shaft speed.
- Fuel and energy mismatch changes combustor temperature or thermal state.

The dynamic model is credible only if rated initialization makes these derivatives close to zero.

## Avoiding Double Counting

Check that each physical effect appears once:

- Pressure loss is not applied both in a component and in a volume.
- Cooling flow is not subtracted twice from compressor delivery flow.
- Fuel mass is not added twice to turbine gas flow.
- Mechanical efficiency is not applied both in turbine work and rotor balance.
- Map efficiency is not multiplied by a separate efficiency unless intended.

## Boundary Conditions

Document boundary choice:

- Generator load or grid speed.
- Propulsor/nozzle/thrust relation.
- Ambient pressure and temperature.
- Exhaust pressure.
- Prescribed fuel flow or controller output.

Changing the boundary can change which variables are solved. Rebuild the matching statement when the application changes.
