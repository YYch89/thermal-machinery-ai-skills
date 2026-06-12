# Thermodynamic Node And Stream Ledger

An energy-conversion model is not ready for component equations until every active stream has a node-by-node ledger.

## Required Schema

Create `thermodynamic_node_stream_ledger.csv` or an equivalent table:

```text
node_id,
node_name,
stream_id,
stream_role,
component_from,
component_to,
state_role,
temperature_variable,
temperature_value,
temperature_unit,
pressure_variable,
pressure_value,
pressure_unit,
mass_flow_variable,
mass_flow_value,
mass_flow_unit,
molar_flow_variable,
molar_flow_value,
molar_flow_unit,
composition_or_quality_variable,
composition_species_order,
composition_or_quality_value,
composition_basis,
enthalpy_or_property_basis,
source_file_or_block,
source_line_or_path,
calculation_status,
closing_residual_or_signal,
notes
```

## Rules

- One row represents one working fluid at one physical node.
- Splits preserve parent stream properties unless a separator, valve, reaction, or phase change is declared.
- Mixers create a new outlet stream with new composition and enthalpy basis.
- Reactors, combustors, evaporators, condensers, and phase-change components create new rows after reaction or phase change.
- Heat exchangers need hot-in, hot-out, cold-in, and cold-out rows.
- Pressure sources and pressure losses must be explicit before downstream pressure ratios or expansion work are calculated.
- Guessed states must be marked `guessed_for_outer_residual` with the residual that closes them.

## Common Failure Patterns

- A temperature variable is reused without identifying the stream.
- Pressure is copied through unit conversions without declaring Pa, kPa, or MPa.
- Mass flow, molar flow, mole fraction, mass fraction, and vapor quality are mixed in one column.
- A heat exchanger is solved from one imposed outlet while the opposite-side inlet is still unknown.
- A dynamic initial condition matches a variable name but not the same node, stream, unit, or basis.
