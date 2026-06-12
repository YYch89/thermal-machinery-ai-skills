# Dynamic Modeling

## Required Dynamic States

Only add dynamic behavior after the steady-state model is validated. For a three-shaft gas turbine, common dynamic states are:

- Low-pressure shaft speed.
- High-pressure shaft speed.
- Power shaft speed.
- Inter-component volume pressures.
- Combustor temperature or fuel/air thermal response.
- Optional actuator states such as fuel valve and IGV.

Before adding these states, draw or inspect a dynamic iteration map. Identify the forward thermodynamic calculation, the volume pressure feedback loops, the shaft-speed feedback loops, and the fuel/load/control inputs. See `dynamic-iteration-map.md`.

For component equations, start from source-backed templates in `component-equation-templates.md` and the property/fuel assumptions in `gas-property-and-combustion.md`. Do not fill missing component physics from memory without evidence.

## Rotor Dynamics

Model each rotor using a power-balance differential equation. The general pattern is:

```text
speed_dot = f(turbine_power - compressor_or_load_power, inertia, current_speed)
speed = integral(speed_dot)
```

For three-shaft models:

- Low-pressure rotor: low-pressure turbine power minus low-pressure compressor power.
- High-pressure rotor: high-pressure turbine power minus high-pressure compressor power.
- Power rotor: power turbine power minus load power.

Use the design-point shaft speeds and inertia estimates as initial conditions. Do not replace shaft dynamics with an arbitrary first-order lag unless the user explicitly requests a low-order approximation.

Before implementing the equation, define the unit convention for power, speed, inertia, and sign direction. If integrating rpm rather than rad/s, document the conversion. See `equations-and-units.md`.

## Volume Pressure Dynamics

Use volume modules to convert mass-flow mismatch into pressure change:

```text
dP/dt = R * T * (G_in - G_out) / V
```

Use air gas constant for air volumes and combustion gas constant for gas volumes. Initial pressures should come from the design point.

Do not integrate `(G_in - G_out)` before using it in the pressure derivative. A structure such as `mass_error_integral = integral(G_in - G_out)` followed by `dP/dt = R*T*mass_error_integral/V` is a suspect double integration unless the model explicitly defines a separate mass state and derives pressure from it. For ordinary pressure-volume modules, the pressure integrator should be driven by the instantaneous flow mismatch.

Before reusing this equation, define the control volume, pressure unit, temperature source, gas constant unit, volume value, and pressure-loss location. See `equations-and-units.md`.

## Combustor Dynamics

A dynamic combustor should handle:

- Fuel flow input and fuel-air ratio.
- Air flow and cooling/bleed effects.
- Gas constant and heat capacity changes.
- Temperature response or thermal inertia.
- Combustor pressure or combustor volume pressure.
- Pressure recovery or pressure loss.

Keep mass balance and energy balance visible. Do not only apply a delay to turbine inlet temperature.

If a combustor is simplified to a thermal lag, label it as empirical and state which mass/energy effects are omitted. For a physics-based combustor state, define the energy state and fuel heat-release term. See `equations-and-units.md`.

## Characteristic Maps

Dynamic compressor and turbine models must not keep design-point flow fixed.

For compressor maps:

- Input corrected speed and pressure ratio.
- Output corrected flow, efficiency, and surge margin if available.
- Apply ambient temperature/pressure correction when converting corrected flow to actual flow.
- Limit extrapolation and document saturation ranges.

For turbine maps:

- Input corrected speed and expansion ratio.
- Output corrected gas flow and efficiency.
- Apply pressure and temperature corrections.
- Use formulas such as Flugel-type corrections only when their assumptions are documented.

Maps may be implemented by lookup tables, curve fits, or fitted neural-network modules. The skill does not require one representation, but the model must expose inputs, outputs, normalization constants, and valid ranges.

If a map is fitted from data, preserve the source data, feature definitions, target definition, fitted model object, training error, and operating range. See `characteristic-map-fitting.md`.

Before using corrected or relative variables, write the formulas for corrected speed, corrected flow, pressure ratio, and expansion ratio. See `equations-and-units.md`.

## Dynamic Coupling Loop

The main dynamic loop is:

1. Shaft speed and pressure ratio enter compressor/turbine map.
2. Map returns flow and efficiency.
3. Flow and efficiency determine component work.
4. Component work determines rotor acceleration.
5. Rotor speed changes and feeds back to maps.
6. Flow mismatch changes volume pressures.
7. Volume pressures feed back to component pressure ratios.

This feedback loop is the core of the dynamic plant. Build and verify it before adding control optimization.

Control objectives are application-dependent. For generator, propulsion, or mechanical-drive models, confirm the control branch and read `control-integration.md` before adding fuel, speed, load, power, frequency, or thrust control.

For off-design or map-based matching, read `off-design-matching.md`. If design-point initial values do not make derivatives close to zero, use `trim-and-initialization.md`.

## Loop-by-Loop Construction

Do not close all dynamic loops in one edit. Use a loop contract for each rotor, volume, combustor, and map feedback loop, then validate the rated initialization after each loop. See `dynamic-loop-build-protocol.md`.

For existing dynamic models, first collect evidence from the executable model: subsystem interfaces, dynamic blocks, initial conditions, workspace variables, characteristic-map wrappers, and feedback connections. See `model-evidence-audit.md`.

## Initial Conditions

Every feedback state block must have a documented initial value. This includes `Memory`, `Delay`, `Unit Delay`, continuous/discrete integrators, transfer functions, and any stateful map or controller block. Prefer design-point values or a converged steady-state run. See `initial-condition-registry.md`.
