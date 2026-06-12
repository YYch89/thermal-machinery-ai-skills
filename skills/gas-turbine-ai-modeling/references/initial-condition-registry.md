# Initial-Condition Registry

## Purpose

Dynamic gas turbine models contain many feedback and state blocks. Every such block needs an explicit initial value and source. Without this registry, the model may run but settle to a result that is not traceable to the design point.

Create or update this registry before adding dynamic feedback loops.

## Blocks That Require Registry Entries

Register every block of these types:

- `Memory`
- `Delay`
- `Unit Delay`
- `Integrator`
- `Discrete-Time Integrator`
- `Transfer Fcn`
- `Discrete Transfer Fcn`
- `Transport Delay` if its history matters
- Stateful MATLAB Function blocks
- Stateful neural-network or lookup-map wrappers

## Required Fields

For each registered block, record:

- Model or subsystem path.
- Block type.
- State variable represented.
- Initial value.
- Unit.
- Source of the initial value.
- Related design-point variable or steady-state signal.
- Sample time or solver context.
- Whether the initial condition is internal, external, inherited, or mask-defined.
- Whether the value is physical, fitted, tuned, or temporary.
- Validation check that confirms the initial value is consistent.

Use this table format:

```markdown
| Path | Block type | State | Initial value | Unit | Source | Check |
| --- | --- | --- | --- | --- | --- | --- |
| GT1/low_pressure_rotor/... | Discrete-Time Integrator | low shaft speed | 7500 | rpm | design point | rotor acceleration near zero |
```

## Minimum Three-Shaft Example

Use this as a minimum template. Replace example values with the user's design-point or steady-state values.

| Path | Block type | State | Initial value | Unit | Source | Check |
| --- | --- | --- | --- | --- | --- | --- |
| GT/low_pressure_rotor/speed_integrator | Discrete-Time Integrator | low-pressure shaft speed | design `N_L0` | rpm | design point | `dN_L/dt` near zero |
| GT/high_pressure_rotor/speed_integrator | Discrete-Time Integrator | high-pressure shaft speed | design `N_H0` | rpm | design point | `dN_H/dt` near zero |
| GT/power_rotor/speed_integrator | Discrete-Time Integrator | power shaft speed | design `N_P0` | rpm | design point | `dN_P/dt` near zero when load matches |
| GT/volume_LPC_HPC/pressure_integrator | Integrator or Discrete-Time Integrator | high-pressure compressor inlet pressure | design `P_HPC_in0` | Pa or MPa | state table | `dP/dt` near zero |
| GT/combustor/pressure_state | Integrator or algebraic state | combustor pressure | design `P3_0` | Pa or MPa | state table | pressure ratio matches design |
| GT/combustor/temperature_state | Integrator, Transfer Fcn, or thermal lag | turbine inlet temperature | design `T3_0` | K | state table | `dT/dt` near zero |
| GT/volume_HPT_LPT/pressure_integrator | Integrator or Discrete-Time Integrator | low-pressure turbine inlet pressure | design `P_LPT_in0` | Pa or MPa | state table | `dP/dt` near zero |
| GT/volume_LPT_PT/pressure_integrator | Integrator or Discrete-Time Integrator | power turbine inlet pressure | design `P_PT_in0` | Pa or MPa | state table | `dP/dt` near zero |
| GT/fuel_path/state_or_delay | Transfer Fcn, Transport Delay, or constant | fuel flow | design `G_f0` | kg/s | design point | combustor residual near zero |
| GT/maps/compressor_map_wrapper | Stateful map wrapper if used | map operating point | design normalized point | dimensionless | map audit | inside valid range |

If an existing model has more stateful blocks than this table, register all of them. The table is a minimum, not a complete inventory.

## Preferred Initial-Value Sources

Use sources in this priority order:

1. Design-point MATLAB solver output.
2. Validated design-point Simulink result.
3. Validated steady-state model at rated input.
4. Physical estimate from geometry or known machine data.
5. Temporary tuning value, clearly marked for later replacement.

Do not invent an initial condition silently.

## Gas Turbine Initial Conditions to Track

For a three-shaft model, track at least:

- Low-pressure shaft speed.
- High-pressure shaft speed.
- Power shaft speed.
- Low-pressure compressor outlet pressure.
- High-pressure compressor inlet pressure.
- High-pressure compressor outlet pressure.
- Combustor pressure.
- High-pressure turbine outlet pressure.
- Low-pressure turbine inlet pressure.
- Low-pressure turbine outlet pressure.
- Power turbine inlet pressure.
- Fuel flow.
- Combustor temperature or turbine inlet temperature.
- Cooling and bleed flow coefficients.
- Compressor and turbine map normalized operating points.

## Repair-Time IC Audit

When an existing dynamic model fails with `NaN`, `Inf`, or a nonphysical state, audit the stateful blocks in the causal path before adding protection logic. A wrong `Memory`, `Delay`, or `Unit Delay` initial value can create a false first-step pulse even when all visible integrators look reasonable.

For each suspicious stateful block, compare:

- The block initial output at `t = 0`.
- The design-point or trim-consistent value of the same physical signal.
- The first-step output after one solver step.
- The residual it creates downstream, such as `G_in - G_out`, pressure ratio, fuel flow, or shaft power imbalance.

If a `Memory` initial condition is nonzero, verify that it is the previous-step value of that same signal. Do not accept an old tuned number as valid merely because it delays a solver failure.

## Consistency Checks

At the design point:

- Shaft accelerations should be close to zero.
- Volume pressure derivatives should be close to zero.
- Combustor temperature derivative should be close to zero.
- Compressor map output flow should match the design flow after correction.
- Turbine map output flow should match the design flow after correction.
- Pressure ratios computed from initial pressures should match the design ratios.

If these are not true, fix the initial values or the steady-state balance before testing transients.

## External Initial Conditions

Some Simulink integrators use an external initial-condition port. For these blocks, the registry must identify both:

- The integrator block path.
- The upstream constant, signal, or workspace variable feeding the initial-condition port.

An integrator with `InitialCondition = 0` may still have a nonzero actual initial value if its source is external. Do not judge it from the block parameter alone.

## Defaults Are Not Evidence

Do not accept default `0`, inherited sample time, or unspecified delay history as valid evidence. If the default is physically correct, state why and connect it to a design-point or steady-state check.

For gas turbine dynamic models, common nonzero initial conditions include shaft speeds, compressor outlet pressures, combustor pressure, turbine inter-stage pressures, fuel flow, and turbine inlet temperature.
