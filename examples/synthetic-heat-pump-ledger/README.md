# Synthetic Heat Pump Ledger Example

> Synthetic reduced workflow artifact. Numeric values are placeholders and are not certified design data, operating limits, or validated machine performance.

This example shows how `thermal-machinery-dynamic-modeling` can describe a non-gas-turbine thermal system using a node ledger and component contracts.

System:

```text
evaporator -> compressor -> condenser -> expansion valve -> evaporator
```

Files:

- `thermodynamic_node_stream_ledger.csv`: compact stream ledger.
- `component_contracts.csv`: compact component contracts.
- `validation_gates.md`: reduced validation checklist.
