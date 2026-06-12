# Sample Three-Shaft Case

## Purpose

This is a compact example of the artifacts an AI should produce. Values are placeholders unless supplied by the user's design-point solver. Do not copy them as machine data.

## Scope

Application: free power turbine generation.

Architecture:

- Low-pressure compressor driven by low-pressure turbine.
- High-pressure compressor driven by high-pressure turbine.
- Power turbine drives generator or load.

Dynamic states:

- Low, high, and power shaft speeds.
- Compressor inter-volume pressure.
- High-pressure turbine to low-pressure turbine volume pressure.
- Low-pressure turbine to power turbine volume pressure.
- Optional combustor temperature or thermal lag.

## Design-Point To Dynamic Mapping Example

| Design-point quantity | Dynamic role | Example value | Unit | Check |
| --- | --- | --- | --- | --- |
| Low shaft speed | Low rotor initial condition | `N_L0` | rpm | low shaft acceleration near zero |
| High shaft speed | High rotor initial condition | `N_H0` | rpm | high shaft acceleration near zero |
| Power shaft speed | Power rotor initial condition | `N_P0` | rpm | power shaft acceleration near zero |
| Low compressor outlet pressure | Compressor volume initial pressure | `P_LPC_out0` | Pa or MPa | compressor volume derivative near zero |
| Combustor pressure | Combustor/turbine inlet pressure | `P_3_0` | Pa or MPa | pressure loss matches design |
| Turbine inlet temperature | Combustor temperature state | `T_3_0` | K | combustor energy residual near zero |
| Fuel flow | Fuel input initial condition | `G_f0` | kg/s | rated power and temperature match |
| Rated compressor flow | Map normalization or map check | `G_c0` | kg/s | map output matches rated flow |

## Low-Pressure Rotor Loop Contract Example

| Field | Example |
| --- | --- |
| Loop name | Low-pressure shaft |
| State variable | Low shaft speed |
| State equation | `dN/dt` from turbine power minus compressor power |
| Inputs | Low-pressure turbine power, low-pressure compressor power, inertia, current speed |
| Outputs | Low shaft speed |
| Feedback destination | Low-pressure compressor map and low-pressure turbine map |
| Initial value | Design-point low shaft speed |
| Zero-derivative check | Low turbine power minus low compressor power within tolerance |
| Isolation test | Hold volume pressures and fuel fixed, verify acceleration near zero |

## Compressor Volume Loop Contract Example

| Field | Example |
| --- | --- |
| Loop name | Low-to-high compressor volume |
| State variable | High-pressure compressor inlet pressure |
| State equation | `dP/dt = R*T*(G_in - G_out)/V` |
| Inputs | Low compressor outlet flow, high compressor inlet flow, representative temperature |
| Outputs | High compressor inlet pressure |
| Feedback destination | High compressor pressure ratio and map input |
| Initial value | Design-point inter-compressor pressure |
| Zero-derivative check | Flow mismatch within tolerance |
| Isolation test | Hold shaft speeds fixed, compare pressure derivative |

## Validation Report Mini-Example

| Item | Example content |
| --- | --- |
| Scenario | Rated dynamic initialization |
| Inputs | Rated fuel flow, rated load, ambient design condition |
| Solver | Declared solver and sample time |
| Tolerances | Pressure, temperature, flow, power, acceleration, and map residual tolerances |
| Low shaft residual | Pass/fail with value |
| High shaft residual | Pass/fail with value |
| Power shaft residual | Pass/fail with value |
| Volume residuals | Pass/fail with values |
| Map range | All initial points inside fitted range or list violations |
| Status | `exploratory`, `reduced`, `design-point checked`, `dynamic-initialization checked`, or `calibrated/externally validated`, with evidence type |

## User Confirmation Prompt Example

Ask one clear question at a gate:

```text
The rated design-point comparison is complete. Pressures, temperatures, air flow, fuel flow, and component powers are within the declared tolerances except [list issues]. Should I proceed to the steady-state Simulink conversion, revise the design-point equations, or investigate the listed differences first?
```
