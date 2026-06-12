# Component Equation Templates

## Purpose

Use these as source-backed templates, not as universal formulas. Before implementing any equation, confirm the application, gas model, units, pressure convention, and literature or user source.

Each component should expose inputs, outputs, equations, assumptions, and validation residuals.

## Equation Contract

Before implementing any component, create a compact equation contract:

| Field | Required content |
| --- | --- |
| Component | compressor, combustor, turbine, volume, rotor, load, cooling/mixing |
| Model stage | design point, steady off-design, dynamic, control-coupled |
| Formula provenance | user model, literature/source, open-source implementation, generic template, empirical fit |
| Inputs | names, units, source blocks or variables |
| Outputs | names, units, downstream consumers |
| State variables | none for algebraic block, or pressure/speed/temperature/actuator states |
| Parameters | efficiencies, pressure losses, inertia, volume, gas properties, map normalizers |
| Equations | exact formula or reference to source file and line/block |
| Valid range | pressure ratio, expansion ratio, temperature, speed, flow, map range |
| Residual checks | mass, energy, work, map, pressure derivative, speed derivative |

If the model is dynamic, the contract must identify which outputs feed back into maps, pressure ratios, expansion ratios, or controller inputs.

## Design-Point Versus Dynamic Use

Do not reuse a design-point equation contract as a dynamic contract without changing its boundary conditions:

| Quantity | Design point | Dynamic/off-design |
| --- | --- | --- |
| Compressor flow | solved from rated power or specified by design | normally produced by map from speed and pressure ratio |
| Compressor pressure ratio | design input or split across stages | depends on volume pressures and map/matching |
| Turbine flow | derived from combustor/cooling design balances | normally produced by turbine map and volume pressures |
| Turbine pressure ratio | solved to satisfy shaft work | depends on upstream/downstream pressure states |
| Fuel flow | solved from target turbine inlet temperature or power | external input, actuator state, or controller output |
| Shaft speed | design reference or fixed rated value | rotor state from power imbalance |
| Volume pressure | algebraic state-point value | dynamic state from flow mismatch |

If both flow and pressure ratio are fixed in a dynamic component, document the matching variable that is being solved elsewhere. Otherwise the model is overconstrained.

## Compressor Template

Typical inputs:

- Inlet total pressure and temperature.
- Pressure ratio or map-derived pressure ratio.
- Mass flow or map-derived corrected flow.
- Compressor efficiency.
- Gas heat capacity and adiabatic exponent.
- Bleed or extraction flow if present.

Typical equations for a simple total-temperature model:

```text
Tt_out_s = Tt_in * pi_c^((gamma_air - 1) / gamma_air)
Tt_out = Tt_in + (Tt_out_s - Tt_in) / eta_c
P_out = P_in * pi_c
W_c = G_air * cp_air * (Tt_out - Tt_in)
```

If the model uses maps, do not hold both mass flow and pressure ratio fixed unless solving a design-point problem. In off-design or dynamic modeling, the compressor map normally supplies corrected flow and efficiency from corrected speed and pressure ratio.

Validation residuals:

- Pressure ratio consistency.
- Work sign and unit consistency.
- Map operating point inside valid range.
- Outlet temperature higher than inlet temperature for compression.
- Bleed mass balance if bleed is modeled.

Dynamic interface requirements:

- Inputs from plant: shaft speed, inlet pressure/temperature, outlet or downstream pressure, bleed/cooling demand if any.
- Map inputs: corrected or relative speed and pressure ratio.
- Map outputs: corrected/relative flow and efficiency.
- Feedback outputs: actual mass flow to neighboring volume, compressor work to rotor, outlet temperature to downstream component.
- Initial check: at rated speed and design pressures, map flow and efficiency reproduce the design-point solver within declared tolerance.

## Turbine Template

Typical inputs:

- Inlet total pressure and temperature.
- Expansion ratio.
- Gas flow.
- Turbine efficiency.
- Gas heat capacity and adiabatic exponent.
- Cooling or mixing flows if present.

Typical equations for a simple total-temperature model:

```text
Tt_out_s = Tt_in * (1 / pi_t)^((gamma_gas - 1) / gamma_gas)
Tt_out = Tt_in - eta_t * (Tt_in - Tt_out_s)
P_out = P_in / pi_t
W_t = G_gas * cp_gas * (Tt_in - Tt_out)
```

State whether expansion ratio is `P_in / P_out` or another convention. Cooling and mixing can change gas flow, heat capacity, and turbine inlet temperature, so document whether they occur before, within, or after the turbine map.

Validation residuals:

- Outlet pressure and temperature decrease through expansion.
- Turbine work sign matches rotor balance convention.
- Map flow and efficiency are inside valid range.
- Cooling/mixing mass and energy residuals are closed.

Dynamic interface requirements:

- Inputs from plant: shaft speed, inlet pressure/temperature, downstream pressure, combustor/cooling information.
- Map inputs: corrected or relative speed and expansion ratio.
- Map outputs: corrected/relative gas flow and efficiency.
- Feedback outputs: actual gas flow to neighboring volume, turbine work to rotor, outlet temperature/pressure to downstream component.
- Initial check: turbine work balances the driven compressor or load at rated initialization.

## Combustor Template

Typical inputs:

- Compressor outlet air flow and temperature.
- Fuel flow, fuel lower heating value, and combustion efficiency.
- Combustor pressure recovery or pressure loss.
- Cooling, dilution, or bypass flows if present.
- Gas property model.

Minimum steady energy-balance pattern:

```text
G_gas = G_air_combustor + G_fuel + sum(G_cooling_or_mixing)
P_t3 = sigma_b * P_t2
energy_in_air + eta_b * G_fuel * Hu + energy_in_cooling = energy_out_gas + losses
```

For a simple constant heat-capacity model:

```text
G_air * cp_air * T_air + eta_b * G_fuel * Hu
  = G_gas * cp_gas * T_gas
```

This simplified form is not enough when variable heat capacity, gas composition, cooling, or excess-air calculation is important. For detailed models, use `gas-property-and-combustion.md`.

Validation residuals:

- Fuel-air ratio and excess-air coefficient are physically plausible.
- Combustor pressure is lower than compressor outlet pressure after pressure loss.
- Mass balance closes.
- Energy residual is within tolerance.
- Turbine inlet temperature matches design or measured data.

Dynamic interface requirements:

- Inputs from plant/controller: compressor air flow, compressor outlet temperature, combustor inlet pressure, fuel flow or fuel actuator state.
- Outputs to plant: turbine inlet temperature, combustor outlet pressure, gas composition/property bus, cooling/bleed coefficients, turbine inlet gas flow.
- State options: combustor pressure, temperature/thermal lag, fuel actuator lag, sensor lag.
- Initial check: mass residual, energy residual, and any pressure/temperature derivative are near zero at rated trim.

## Cooling, Bleed, and Mixing Template

Typical inputs:

- Extraction source pressure, temperature, and mass flow.
- Injection or mixing location.
- Mainstream gas flow and temperature.
- Cooling effectiveness or empirical coefficients.
- Mixing pressure loss if modeled.

Generic mass and energy balance:

```text
G_mix = G_main + G_cool
G_mix * h_mix = G_main * h_main + G_cool * h_cool
```

If using heat capacities rather than enthalpy, state the temperature range and property model.

Validation residuals:

- Cooling or bleed flow is nonnegative and bounded.
- Extraction reduces downstream compressor/combustor/turbine flow consistently.
- Mixing temperature lies between physically meaningful limits unless heat release or work is present.
- Pressure loss is applied once, not duplicated.

Dynamic interface requirements:

- Extraction must reduce the source component flow before downstream work calculations.
- Injection must increase the receiving turbine or combustor gas flow before work calculation if the user model assumes it does.
- Mixing enthalpy/property updates must be traceable to either a formula, user code, or an empirical fit.
- Cooling coefficients used as initial values must be mapped from the design-point solver or trim result.

## Volume Template

Typical inputs:

- Inlet and outlet mass flows.
- Representative temperature.
- Gas constant.
- Volume.
- Initial pressure.

Simple pressure-state model:

```text
dP/dt = R * T * (G_in - G_out) / V
```

Use this only after documenting whether pressure is total pressure, static pressure, or a lumped state. Record whether pressure loss belongs to the volume or neighboring component.

Validation residuals:

- At trim, `G_in - G_out` is close to zero.
- Pressure derivative is close to zero at rated initialization.
- Pressure feeds back to the correct pressure ratio or expansion ratio.

Dynamic interface requirements:

- State block type and initial condition must be recorded.
- Incoming and outgoing flow sign conventions must be explicit.
- Pressure unit must match all neighboring compressor/turbine pressure-ratio calculations.
- The volume should not duplicate pressure losses already applied in neighboring components.

## Rotor Template

Typical inputs:

- Turbine work or power.
- Compressor work, load power, or driven machine power.
- Inertia.
- Current shaft speed.
- Mechanical efficiency if used.

For a shaft-speed state in rpm with power in W:

```text
dN/dt = 900 * (P_turbine - P_load_or_compressor) / (pi^2 * J * N)
```

If power is in kW, include the `1000` conversion or document that the inertia parameter is scaled.

Validation residuals:

- At design point, rotor acceleration is close to zero.
- Positive power imbalance increases shaft speed.
- The speed state feeds back to the correct compressor and turbine maps.

Dynamic interface requirements:

- State block type and initial speed must be recorded.
- Power units must be consistent with inertia and speed units.
- The shaft must list all driven and driving components.
- For a three-shaft model, write one separate contract for low-pressure, high-pressure, and power shaft loops.

## Load Template

For generator or mechanical-drive loads, document:

- Load type: generator, propulsor, compressor, pump, or prescribed torque/power.
- Torque-speed or power-speed relation.
- Inertia included in load or shaft.
- Grid-connected or islanded behavior if electrical.
- Control interaction.

Validation residuals:

- Load power sign matches rotor balance.
- Rated load matches design power.
- Load changes produce expected shaft acceleration before controller action.

Dynamic interface requirements:

- For generation, declare whether the boundary is grid-connected speed/frequency, islanded load, prescribed torque, prescribed power, or generator electrical dynamics.
- For propulsion, declare whether load is propulsor/fan/nozzle/thrust coupling rather than generator power.
- For mechanical drive, declare torque-speed or process-load behavior.
- Do not attach a controller until the open-loop plant and load boundary initialize consistently.
