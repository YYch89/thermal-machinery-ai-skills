# Validation And Deliverables

Use this file before claiming a model is complete.

## Minimum Checks

- Topology matches the requested system boundary and working-fluid paths.
- Node ledger covers every active stream and node.
- Units and flow/composition bases are explicit.
- Mass balance closes.
- Species, element, or phase-quality balance closes when relevant.
- Energy balance closes for components and the whole system.
- Pressure changes are physically directional except across pumps, compressors, and explicit pressure sources.
- Heat exchangers have feasible terminal temperature differences.
- Dynamic states initialize near the design or trim point.
- Simulations have no `NaN`/`Inf`, negative impossible states, or hidden controller-only stabilization.
- Control or optimization is judged against constraints and an open-loop or baseline case.

## Acceptance Starting Points

Use project tolerances when available. If none exist, start with:

- mass balance error below `0.1%` for design-point tables;
- steady energy balance error below `1%`;
- pressure initial mismatch below `0.5%` to `1%`;
- major temperature initial mismatch below `2 K` to `5 K` or `0.5%`;
- mole-fraction absolute error below `1e-3`;
- normalized dynamic residual below `1e-4` when defined.

These are engineering starting points, not universal certification criteria.

## Deliverables

Provide:

- scope and assumptions;
- topology or stream-routing description;
- thermodynamic node and stream ledger;
- component contracts;
- state-point table;
- design-to-dynamic map;
- initial-condition audit;
- validation report;
- unresolved assumptions and required data.
