# Design-Point Solver

## Purpose

The design-point solver is the anchor for all later models. It converts design requirements into a rated thermodynamic state table and reference quantities.

Typical inputs:

- Total pressure ratio and compressor split pressure ratios.
- Turbine inlet temperature or maximum cycle temperature.
- Ambient pressure and temperature.
- Component efficiencies.
- Total pressure recovery or pressure loss coefficients.
- Fuel lower heating value and stoichiometric air requirement.
- Cooling or bleed assumptions.
- Rated effective power.

Typical outputs:

- State-point pressures and temperatures.
- Air flow and combustor air flow.
- Fuel flow.
- Fuel-air ratio or excess-air coefficient.
- Compressor works.
- Turbine works.
- Specific power and thermal efficiency.
- Cooling/bleed flow coefficients.

## Calculation Pattern

For a three-shaft gas turbine design point, follow this pattern:

1. Calculate low-pressure compressor temperature rise, pressure outlet, heat capacity, and adiabatic exponent.
2. Calculate high-pressure compressor stages in the same way.
3. Calculate combustor fuel-air ratio, excess-air coefficient, combustion product heat capacity, and combustor outlet pressure.
4. Calculate cooling and bleed flow coefficients and update combustor/turbine gas flow coefficients.
5. Calculate high-pressure turbine expansion and mixing so that it drives the high-pressure compressor.
6. Calculate low-pressure turbine expansion and mixing so that it drives the low-pressure compressor.
7. Calculate power turbine expansion, power output, exhaust state, and system performance.
8. Back-calculate rated air flow from rated power and specific power.

For component-level equations, use `component-equation-templates.md` as a checklist and `gas-property-and-combustion.md` for fuel, heat-capacity, gas constant, and combustion assumptions. Replace template equations with the user-provided or source-backed formulas when they differ.

## Iteration Rules

Use iteration when heat capacity, adiabatic exponent, fuel-air ratio, or cooling flow depends on the unknown output temperature or flow coefficient.

For MATLAB implementation:

- Give every iterative variable an initial value from engineering expectation or previous design point.
- Use a convergence tolerance and a maximum iteration count.
- Record the final iteration count or convergence flag.
- Avoid relying on symbolic `eval` in new code when numerical functions or numerical integration are available.

For Simulink conversion:

- Replace `while` loops with feedback and memory/delay elements when a block-level iterative relation is required.
- Use design-point outputs as initial conditions for feedback paths.
- Break algebraic loops intentionally with `Memory`, `Unit Delay`, or discrete integrators.

## State Table Discipline

Create a state table with at least:

- State name or number.
- Component location.
- Total pressure.
- Total temperature.
- Mass flow or relative flow coefficient.
- Working fluid type: air, combustion gas, or mixed gas.
- Heat capacity and gas constant if variable properties are used.

Do not let state-point names drift between MATLAB and Simulink. If a model uses names such as `T21`, `P21`, `T3`, `P3`, `T41`, `P41`, keep a mapping table.
