# Artifact Templates

Use these compact templates when the user wants a quick plan instead of full CSV files.

## `scope_and_topology.md`

| Field | Content |
| --- | --- |
| Goal | Target output and model use |
| Boundary | Inlets, outlets, environment, load |
| Working fluids | Fluids, composition, phase assumptions |
| Components | Ordered component list |
| Control objective | Speed, power, temperature, pressure, efficiency, safety |
| Missing data | Required values or sources |

## `thermodynamic_node_stream_ledger.csv`

| node_id | stream_id | from -> to | role | T | P | mass_flow | molar_flow | composition/quality | unit/basis | status | residual |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| N0 | stream_0 | boundary -> component | inlet | missing | missing | missing | optional | missing | declare | required_input | named residual |

## `component_contracts.csv`

| component | inputs | outputs | parameters | states | residuals | validation checks |
| --- | --- | --- | --- | --- | --- | --- |
| component name | ledger nodes | ledger nodes, work/heat | units and sources | optional dynamic states | balance equations | physical checks |

## `design_to_dynamic_map.csv`

| design or steady item | dynamic target | source | unit | acceptance check |
| --- | --- | --- | --- | --- |
| state value | IC, lookup, signal, or controller reference | ledger/state table | unit | derivative or residual near zero |

## `validation_report.md`

| Gate | Required evidence | Status |
| --- | --- | --- |
| Topology | stream graph and boundary | open/pass/fail |
| Ledger | all active streams have T/P/flow/composition | open/pass/fail |
| Balances | mass/species/energy/pressure residuals | open/pass/fail |
| Dynamic initialization | derivatives/residuals near trim | open/pass/fail |
| Limitations | missing data and assumptions | open/pass/fail |
