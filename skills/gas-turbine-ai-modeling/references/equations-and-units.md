# Equations and Units

## Purpose

Dynamic gas turbine models fail easily when units and sign conventions are implicit. Before implementing rotor, volume, combustor, or map equations, write the variable definitions and units used by the model.

This file gives minimum conventions to document. It does not replace the user's thermodynamic equations or source references.

## Global Unit Rules

Declare one unit system before building:

| Quantity | Preferred unit | Common risk |
| --- | --- | --- |
| Temperature | K | Celsius accidentally used in gas-property or corrected-flow formulas |
| Pressure | Pa or MPa, consistently | Missing `1e6` factor when using MPa in ideal-gas dynamics |
| Mass flow | kg/s | Fuel flow given as kg/h but used as kg/s |
| Power | W or kW, consistently | Rotor acceleration formula missing `1000` if power is kW |
| Shaft speed | rpm or rad/s, explicitly converted | Rotor dynamics derived in rad/s but integrated in rpm |
| Inertia | kg*m^2 or an identified equivalent constant | Fitted inertia constant mixed with physical inertia |
| Gas constant | J/(kg*K) if pressure is Pa; kJ/(kg*K) if pressure is kPa | Unit mismatch in volume pressure dynamics |

If an existing model uses MPa, kJ, or kW, record the conversion factors in the loop contract.

## Rotor Dynamics Convention

A physical rotor balance is normally based on angular speed:

```text
J * d(omega)/dt = torque_turbine - torque_load
power = torque * omega
d(omega)/dt = (P_turbine - P_compressor_or_load) / (J * omega)
```

If the integrated state is shaft speed `N` in rpm:

```text
omega = pi * N / 30
dN/dt = 30/pi * d(omega)/dt
```

For power in W:

```text
dN/dt = 900 * (P_turbine - P_compressor_or_load) / (pi^2 * J * N)
```

If power is in kW, multiply the numerator by `1000`, unless the inertia parameter has already been scaled. Do not hide this scaling inside an unnamed gain.

For every rotor, document:

- Shaft name.
- Driven compressor or load.
- Turbine power signal and unit.
- Compressor or load power signal and unit.
- Inertia parameter and source.
- Speed state unit.
- Sign convention: positive acceleration means speed increases.
- Initial speed and design-point zero-acceleration check.

## Volume Pressure Dynamics Convention

A simple volume module usually uses a gas-storage relation:

```text
dP/dt = R * T * (G_in - G_out) / V
```

This equation is only complete after documenting:

- Control-volume boundary.
- Whether pressure is total pressure, static pressure, or a lumped approximation.
- Whether `T` is inlet, outlet, mixed, or state temperature.
- Whether `R` is air gas constant or combustion-gas gas constant.
- Whether pressure loss is handled inside the volume or in neighboring component blocks.
- Mass-flow sign convention.
- Volume value and source.
- Unit conversion factor for pressure.

If pressure is represented in MPa and `R*T*G/V` is computed in Pa/s, multiply by `1e-6` before integration.

Do not reuse one volume formula across compressor, combustor, and turbine regions without checking gas type, pressure convention, and temperature source.

Do not drive this pressure derivative with a previously integrated flow residual. Unless the model explicitly defines mass as the state and derives pressure from that mass state, the pressure-state input should be the instantaneous `G_in - G_out` residual with the correct unit conversion.

Minimum location guidance:

| Volume location | Gas type | Temperature choice to document | Pressure-loss handling |
| --- | --- | --- | --- |
| Between low- and high-pressure compressors | Air | Upstream compressor outlet, downstream inlet, or lumped state temperature | Usually outside the volume unless explicitly lumped |
| Combustor | Reacting or mixed gas | Combustor gas temperature or turbine inlet temperature state | Combustor pressure recovery/loss must be explicit |
| Between high- and low-pressure turbines | Combustion gas with cooling/mixing effects | Upstream turbine outlet or mixed gas state | Turbine expansion loss usually outside the volume |
| Between low-pressure and power turbines | Combustion gas | Low-pressure turbine outlet or mixed gas state | Expansion ratio feedback must remain traceable |

If a project uses a different partition, keep the project partition and record it in the iteration map.

## Combustor Dynamic Convention

A dynamic combustor should expose mass and energy balances. At minimum, document:

- Incoming compressor air flow.
- Fuel flow and fuel lower heating value.
- Cooling or bleed flows entering or bypassing the combustor.
- Combustor outlet gas flow.
- Pressure loss or pressure recovery relation.
- Temperature state, pressure state, or both.
- Thermal inertia or gas storage assumption.

A generic energy-balance form is:

```text
dE/dt = sum(G_in * h_in) + eta_b * G_fuel * Hu - G_out * h_out - Q_loss
```

The model may simplify this to a first-order turbine-inlet-temperature state only if the simplification is explicitly requested or justified. If only a delay is used, mark the combustor as an empirical thermal lag rather than a full mass-energy dynamic model.

For a physics-based combustor state, state how `E`, `h`, `cp`, gas composition, and fuel-air ratio are represented.

At first-version skill level, do not invent combustion chemistry or gas-property models. Use user-provided formulas, a cited thermodynamic model, or mark the combustor as simplified with stated limitations.

## Characteristic-Map Variable Conventions

For every compressor or turbine map, write the actual formulas used for corrected or relative quantities. Common definitions are:

```text
theta = T_in / T_ref
delta = P_in / P_ref
N_corr = N / sqrt(theta)
G_corr = G * sqrt(theta) / delta
```

Relative maps may instead use:

```text
n_rel = N / N_design
g_rel = G_corr / G_corr_design
```

Do not mix corrected and relative quantities without a mapping statement.

For compressor maps, define:

- Pressure ratio direction, usually `Pi_c = P_out / P_in`.
- Inputs to the map.
- Outputs from the map.
- Conversion from map flow to actual flow.
- Efficiency correction and saturation.
- Surge boundary or range check.

For turbine maps, define:

- Expansion ratio direction, for example `Pi_t = P_in / P_out`.
- Inputs to the map.
- Outputs from the map.
- Conversion from corrected gas flow to actual gas flow.
- Whether cooling and mixing are inside or outside the map.

If a source uses a different convention, keep the source convention and document it explicitly.
