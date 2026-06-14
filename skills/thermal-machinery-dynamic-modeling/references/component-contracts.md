# Component Contracts

Use this file before implementing or reviewing component equations.

## Universal Contract

For every component, record:

- input stream rows from the ledger;
- output stream rows from the ledger;
- parameters and units;
- algebraic equations;
- dynamic states, if any;
- residuals and closure targets;
- closure depth: prescribed target, algebraic equilibrium, steady correlation, reduced progress state, or inventory-based dynamic model when relevant;
- validation checks;
- source of equations or assumptions.

Temperature alone does not connect components. Temperature, pressure, flow, and composition or phase quality must travel together.

## Common Components

### Compressor, Pump, Fan

Inputs: inlet state, pressure ratio or outlet pressure, efficiency, speed or map input.

Outputs: outlet pressure, outlet temperature or enthalpy, work, flow, map validity.

Checks: pressure rise direction, efficiency range, map domain, power sign, surge or operating margin when relevant.

### Turbine, Expander

Inputs: inlet state, outlet pressure or expansion ratio, efficiency, speed or map input.

Outputs: outlet state, work, flow, map validity.

Checks: pressure drop direction, positive work extraction, outlet temperature, map range, shaft balance.

### Heat Exchanger

Inputs: hot and cold inlet states, flow arrangement, UA/effectiveness or target outlet, pressure losses.

Outputs: hot and cold outlet states, heat duty, terminal temperature differences.

Checks: no unexplained temperature crossing, heat-duty mismatch, pressure-loss direction, heat-grade suitability, material and process limits.

### Mixer, Splitter, Valve

Mixers close mass, species, energy, and pressure assumptions. Splitters preserve parent composition unless separation is modeled. Valves apply pressure loss and may require phase or choking checks.

### Combustor, Reactor, Fuel Processor

Inputs: reactants, oxidizer or heat source, pressure, temperature, residence or reaction assumptions.

Outputs: products, heat release or absorption, outlet state, pressure loss, conversion.

Checks: element balance, nonnegative species, oxygen or reactant availability, temperature limits, kinetic or equilibrium provenance.

Do not infer dynamic rate constants, phase-transfer coefficients, or distributed heat-transfer parameters from a single rated point unless the model is explicitly calibrated and labeled.

### Volume, Plenum, Thermal Capacity

States: pressure, mass, species inventory, wall temperature, fluid temperature, or stored energy.

Checks: state derivatives near zero at intended steady initialization, finite properties, no hidden controller action required to stabilize the plant.

Control variables must map to a physical actuator, shaft/load interaction, heat source, valve, electric device, or storage term. Do not transfer a control strategy between configurations without checking that this authority exists.
