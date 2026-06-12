# Dynamic Iteration Map

## Purpose

Before building a dynamic gas turbine model, create an iteration map. The map should show the order of thermodynamic calculation and every feedback loop that changes pressure, flow, temperature, or shaft speed.

For a three-shaft gas turbine, this map is not optional. The dynamic model has multiple coupled loops, and Simulink block construction should follow the map rather than ad hoc subsystem wiring.

## Main Forward Calculation

Use this forward calculation order as the baseline:

1. Ambient condition enters the low-pressure compressor.
2. Low-pressure compressor map uses shaft speed and pressure ratio to calculate compressor characteristic parameters, outlet flow, outlet temperature, and compressor work.
3. First volume module uses low-pressure compressor outlet flow and high-pressure compressor inlet flow to update high-pressure compressor inlet pressure.
4. High-pressure compressor map uses shaft speed and pressure ratio to calculate outlet pressure, outlet gas state, inlet/outlet flow, and compressor work.
5. Combustor uses high-pressure compressor outlet state and fuel flow to calculate energy conservation, mass conservation, cooling/bleed mixing, combustor pressure, turbine inlet temperature, and turbine inlet gas flow.
6. High-pressure turbine map uses turbine speed and expansion ratio to calculate gas flow, efficiency, cooling-air mixing, and turbine work.
7. Second volume module uses high-pressure turbine outlet flow and low-pressure turbine inlet flow to update low-pressure turbine inlet pressure.
8. Low-pressure turbine map uses turbine speed and expansion ratio to calculate gas flow, efficiency, and turbine work.
9. Third volume module uses low-pressure turbine outlet flow and power turbine inlet flow to update power turbine inlet pressure.
10. Power turbine map uses power-shaft speed and expansion ratio to calculate gas flow, power turbine work, and exhaust state.
11. Load model consumes power turbine work and closes the power-shaft balance.

This is the executable thermodynamic dependency order. It is not a command to close every Simulink feedback loop in this order. When implementing loops, use `dynamic-loop-build-protocol.md`: add map wrappers under held design-point conditions, then close volume and rotor states one by one.

## Feedback Loops

Track at least these loops:

- **Low-pressure shaft loop:** low-pressure compressor work and low-pressure turbine work enter power balance, update low-pressure shaft speed, then feed back to low-pressure compressor and low-pressure turbine maps.
- **High-pressure shaft loop:** high-pressure compressor work and high-pressure turbine work enter power balance, update high-pressure shaft speed, then feed back to high-pressure compressor and high-pressure turbine maps.
- **Power shaft loop:** power turbine work and load enter power balance, update power shaft speed, then feed back to power turbine map.
- **Compressor inter-volume loop:** low-pressure compressor outlet flow and high-pressure compressor inlet flow update high-pressure compressor inlet pressure, which changes high-pressure compressor pressure ratio.
- **Turbine inter-volume loops:** upstream turbine outlet flow and downstream turbine inlet flow update downstream turbine inlet pressure, which changes turbine expansion ratios.
- **Combustor loop:** fuel flow, air flow, cooling/bleed flow, and turbine inlet gas flow set combustor pressure and temperature response.

## Map Inputs and Outputs

For each compressor map, document:

- Corrected or relative speed.
- Pressure ratio.
- Corrected or relative mass flow.
- Efficiency.
- Surge boundary or surge margin if available.

For each turbine map, document:

- Corrected or relative speed.
- Expansion ratio.
- Corrected or relative gas flow.
- Efficiency.
- Pressure/temperature correction formula.

## Build Order for Dynamic Loops

Use this order when constructing or reviewing a Simulink dynamic model:

1. Build the forward steady thermodynamic chain without controllers.
2. Add map-based flow and efficiency for compressors.
3. Add map-based flow and efficiency for turbines.
4. Add volume pressure states between components.
5. Add shaft power-balance states.
6. Add combustor temperature and pressure states.
7. Add fuel actuator, load schedule, IGV, or controller logic.
8. Validate design-point initialization before transient testing.

## Iteration Map Deliverable

Before editing a dynamic model, prepare a short text map listing:

- Blocks or subsystems in forward order.
- Feedback state variables.
- Feedback block type used in Simulink.
- Initial value source.
- Variables that may create algebraic loops.
- Validation signal for each loop.

## Dependency Trace

For every arrow in the iteration map, record whether the signal is:

- A thermodynamic state such as pressure, temperature, or mass flow.
- A map input such as corrected speed, pressure ratio, or expansion ratio.
- A map output such as corrected flow or efficiency.
- A dynamic state such as shaft speed or volume pressure.
- A controller or boundary input such as fuel flow, load, ambient condition, or IGV position.

This prevents an AI agent from drawing a visually plausible loop without knowing what each signal means.

## Loop Closure Rule

A loop is considered closed only when all four items are present:

1. A state equation or update equation.
2. A state block with documented initial value.
3. A feedback destination that changes a compressor, combustor, turbine, load, or map calculation.
4. A design-point check showing near-zero derivative or near-zero acceleration.

If one item is missing, describe the loop as partially specified.
