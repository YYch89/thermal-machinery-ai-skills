# Characteristic Map Fitting

## Purpose

Dynamic gas turbine models require compressor and turbine characteristic maps. A design-point flow is not enough. The map provides flow and efficiency as functions of corrected speed, pressure ratio, expansion ratio, corrected flow, guide-vane position, or another project-defined map coordinate.

Maps may come from digitized curves, spreadsheets, lookup tables, polynomial fits, neural networks, or GA-BP neural-network fits. The representation may vary, but the documentation requirements do not.

## Source Data Requirements

For each map, preserve:

- raw data source or public/synthetic dataset name;
- component name;
- feature columns and units;
- target column and unit;
- corrected or relative speed lines;
- pressure ratio or expansion ratio range;
- flow range;
- efficiency range;
- design-point operating point;
- interpolation, extrapolation, saturation, and validity rules.

For spreadsheet-based data, explicitly identify which columns are features and which column is the target. For example, a fitting script may read input features from columns `B:C` and a target from column `A`; the feature meanings must still be documented.

## Fitted Model Requirements

For each fitted map, record:

- fitting method: lookup, polynomial, interpolation, BP neural network, GA-BP neural network, Gaussian process, or another declared method;
- input normalization constants;
- output normalization constants;
- training data range;
- error metric such as MSE, RMSE, max relative error, or rated-point residual;
- saved model variable names;
- saturation or extrapolation behavior;
- model file, block path, or function name that uses the fitted map.

If using a neural network, do not treat it as an unexplained black box. Document its inputs, outputs, hidden size if known, training data, and the physical meaning of each signal in the Simulink wrapper.

## GA-BP Reference Pattern

Some three-shaft gas-turbine projects fit characteristic maps with script-driven GA-BP networks and then embed or mirror the trained models in Simulink map subsystems.

Public synthetic examples:

| Script | Data read | Target | Fitting call pattern |
| --- | --- | --- | --- |
| `fit_lpc_map.m` | compressor map, feature range `B:C` | corrected flow or efficiency | `fitMapModel(features,target,options)` |
| `fit_hpc_map.m` | compressor map, feature range `B:C` | pressure ratio or efficiency | `fitMapModel(features,target,options)` |
| `fit_turbine_map.m` | turbine map, feature range `A:B` | reduced flow or efficiency | `fitMapModel(features,target,options)` |

Typical GA-BP behavior:

- build an initial BP network;
- train and simulate raw BP output;
- use genetic algorithm selection, crossover, and mutation to optimize weights and biases;
- reassign optimized weights and biases to the network;
- retrain and return fitted output plus error traces.

When using this pattern, require an audit table that links:

- raw spreadsheet range;
- meaning of each feature column;
- target variable;
- saved model variables such as `net`, `features`, `target`, `prediction`, and error traces;
- Simulink map subsystem and any generated neural-network block;
- rated operating point and map residual at that point.

Do not describe a neural-network map as a simple lookup table unless the network has actually been replaced by a validated lookup-table implementation.

## Map Topology Classification

Before fitting or converting a map, classify the source:

| Source type | Handling rule |
| --- | --- |
| Regular rectangular table | Can use `2-D Lookup Table` if axes, units, and extrapolation are documented. |
| Speed-line curve family | Preserve speed-line identity and check interpolation between lines. |
| Scattered map points | Do not pretend the entire rectangular bounding box is valid. |
| Neural-network map | Preserve training data, normalization, and residual evidence. |
| Polynomial or empirical fit | Record fit range and do not extrapolate without a validity flag. |
| Digitized image curve | Record digitization method and uncertainty. |

## Dynamic Model Checks

Before using a fitted map in a dynamic model, check:

- design-point inputs produce design-point flow and efficiency within tolerance;
- transient inputs stay inside the valid map domain or trigger a documented saturation rule;
- flow derivatives do not become discontinuous enough to destabilize pressure-volume loops;
- map normalization uses the same corrected speed, corrected flow, pressure ratio, and temperature conventions as the dynamic equations;
- surge, choke, or map-boundary flags are available when the controller or validation report depends on them.

## Replacement Rule

Replacing a neural-network map with a lookup table, polynomial fit, or simpler approximation is allowed only when the replacement preserves or improves:

- valid operating range;
- rated-point residual;
- dynamic smoothness;
- extrapolation or saturation behavior;
- physical monotonicity where expected;
- downstream shaft, volume, and combustor validation results.

If the original map source cannot be audited, mark the replacement as exploratory and do not claim validated equivalence.
