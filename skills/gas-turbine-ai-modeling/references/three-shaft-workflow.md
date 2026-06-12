# Three-Shaft Gas Turbine Workflow

## Modeling Object First

Before selecting equations, identify the gas turbine structure:

- Low-pressure compressor, high-pressure compressor, combustor, high-pressure turbine, low-pressure turbine, and power turbine.
- Three shaft speeds: low-pressure shaft, high-pressure shaft, and power/output shaft.
- Power balance pairings: high-pressure turbine drives high-pressure compressor; low-pressure turbine drives low-pressure compressor; power turbine drives load.
- Cooling and bleed paths: identify extraction source, injection location, and whether they affect combustor air flow or turbine gas flow.

Do not reuse single-shaft or two-shaft equations without checking shaft coupling and work balance.

## Stage-Gated Build Order

Use this build sequence:

1. **Design point:** calculate rated state points and reference flows from design requirements.
2. **Design-point Simulink model:** reproduce the MATLAB design-point result in Simulink, including iterative heat capacity and flow coefficient calculations.
3. **Steady-state model:** replace design requirements with physical inputs such as air flow and fuel flow, and compute actual output power and turbine inlet temperature.
4. **Dynamic model:** add rotor speeds, volume pressures, combustor thermal dynamics, compressor/turbine maps, fuel actuator dynamics, and optional IGV/load/control modules.

At each stage, compare the new model with the previous stage under rated conditions before adding new behavior.

## Traceability Rule

Every dynamic initial condition should trace back to the design point or a documented physical assumption. This includes:

- Initial compressor outlet pressures and temperatures.
- Initial combustor pressure and turbine inlet temperature.
- Initial shaft speeds.
- Initial fuel flow and air flow.
- Initial volume pressures.
- Initial compressor/turbine map operating points.

If an initial condition is tuned only to make the simulation stable, mark it as a tuning value and verify it later.

## Modular Architecture

Use component subsystems rather than a monolithic model:

- Low-pressure compressor.
- High-pressure compressor.
- Combustor.
- High-pressure turbine.
- Low-pressure turbine.
- Power turbine.
- Low-pressure rotor.
- High-pressure rotor.
- Power rotor.
- Inter-component volume modules.
- Characteristic-map modules.
- Fuel actuator and controller modules only after plant behavior is working.

Each subsystem should expose physically meaningful ports such as pressure, temperature, mass flow, fuel flow, shaft speed, work, and bus information.
