# Model Evidence Audit

## Purpose

Before changing a large MATLAB/Simulink gas turbine model, collect evidence from the files. Do not rely only on screenshots or subsystem names. The audit should explain what the model actually computes and where dynamic feedback enters the calculation.

Use this audit when the task involves an existing `.m`, `.slx`, characteristic-map folder, or dynamic model validation.

If the existing model already fails during simulation, pair this audit with `existing-model-debug-and-repair.md`. First collect the executable evidence, then trace the earliest nonphysical signal upstream from the reported solver error block.

## Artifact Inventory

List the artifacts and their role:

| Artifact | Role | Evidence to extract |
| --- | --- | --- |
| Design-point MATLAB script | Rated thermodynamic state and reference quantities | Inputs, outputs, iteration variables, state table, flow and fuel values |
| Design-point Simulink model | Formula transfer from MATLAB to Simulink | Subsystems, interfaces, feedback or memory blocks, comparison to MATLAB |
| Steady-state Simulink model | Input-output thermodynamic plant | Air and fuel inputs, pressure ratios, component works, rated reproduction |
| Dynamic Simulink model | Rotor, volume, combustor, and map feedback | Dynamic states, feedback loops, initial values, solver settings |
| Characteristic-map scripts/data | Compressor and turbine map source | Raw data, feature columns, target columns, fitted model, valid ranges |

Do not infer a missing artifact. Mark it as unavailable and state the effect on validation.

## MATLAB Script Evidence

For a design-point or map-fitting script, extract:

- Design inputs such as power, pressure ratio, turbine inlet temperature, ambient state, efficiencies, and pressure losses.
- Named outputs such as state pressures, temperatures, air flow, fuel flow, work, efficiency, cooling or bleed coefficients.
- Iteration variables and stopping criteria.
- Saved variables and `.mat` outputs.
- Any use of symbolic heat-capacity integration, neural-network training, or optimization.

When the script uses old functions such as `eval`, `newff`, or `xlsread`, do not rewrite it unless asked. Record the behavior and note modernization only as a risk or future improvement.

## Simulink Evidence

For each important `.slx` model, collect:

- Top-level subsystem hierarchy.
- Input and output ports for each main component.
- Connections among compressor, combustor, turbine, volume, rotor, map, fuel, and load subsystems.
- Block counts for stateful elements such as `Memory`, `Unit Delay`, `Integrator`, `Discrete-Time Integrator`, `Transfer Fcn`, `Transport Delay`, and stateful MATLAB Function blocks.
- Solver settings and sample times where they affect feedback.
- Model workspace or base workspace parameters used by blocks.
- For failed simulations, the first `NaN`, `Inf`, negative pressure, negative temperature, negative flow, invalid pressure ratio, invalid shaft speed, or invalid map-domain signal.

For a dynamic model, the audit is incomplete unless it identifies all rotor states, volume pressure states, combustor states, and characteristic-map modules.

## Mandatory Simulink Tool Audit

When Simulink Agentic Toolkit or MATLAB Simulink APIs are available, the audit must include evidence from executable model inspection, not only screenshots or block names.

For a first-pass read-only inventory, an agent may run:

```matlab
addpath("path/to/gas-turbine-ai-modeling/scripts")
report = audit_simulink_gasturbine("modelName", "OutputDir", "audit_modelName");
```

Use the generated dynamic-state, lookup/map, function-block, routing, workspace-variable, and named-candidate tables to guide deeper inspection. The script output is an evidence index, not a substitute for physical interpretation or simulation.

Minimum tool sequence:

1. `model_overview` at root or an equivalent Simulink API hierarchy query.
2. `model_read` for the top-level plant and each major dynamic subsystem.
3. `model_query_params`, `model_resolve_params`, or `get_param` for stateful block parameters and workspace variables.
4. Targeted inspection of `Fcn`, MATLAB Function, lookup, neural-network, and map-wrapper blocks that determine thermodynamic behavior.

Minimum extracted items:

| Item | Required evidence |
| --- | --- |
| Model configuration | solver type, stop time if relevant, sample time or fixed-step setting if relevant |
| Main subsystem interfaces | input/output ports for compressors, combustor, turbines, volumes, rotors, maps, fuel, load |
| Dynamic state blocks | block path or ID, block type, state meaning, initial condition, IC source, sample time |
| Delay/memory blocks | block path or ID, block type, initial condition, feedback loop role |
| Algebraic/function blocks | expression or MATLAB Function purpose for rotor, volume, combustor, map correction, work calculation |
| Goto/From or bus signals | tag or bus field names for work, speed, flow, pressure, temperature, fuel, cooling signals |
| Workspace parameters | parameter name, resolved value when available, blocks using it |
| Characteristic maps | map block, input variables, output variables, normalization constants, saturation limits |
| Fuel/control/load path | fuel source, limiter, actuator/delay/controller blocks, load input or generator model |

If a tool call fails, record:

- The attempted tool and scope.
- The error or missing dependency.
- The fallback used, such as MATLAB batch with SATK functions or direct Simulink API.
- Which evidence remains unavailable.

Do not mark a model audit complete if all stateful blocks, map wrappers, and rotor/volume feedback paths have not been inspected.

## Dynamic Evidence To Extract

A three-shaft dynamic model should provide evidence for these coupled loops:

| Loop | Required evidence |
| --- | --- |
| Low-pressure shaft | Compressor work, turbine work, inertia, speed state, speed feedback to maps |
| High-pressure shaft | Compressor work, turbine work, inertia, speed state, speed feedback to maps |
| Power shaft | Power turbine work, load, inertia, speed state, speed feedback to map |
| Compressor volume | Upstream compressor flow, downstream compressor flow, pressure state, pressure-ratio feedback |
| Turbine volumes | Upstream turbine flow, downstream turbine flow, pressure state, expansion-ratio feedback |
| Combustor | Air flow, fuel flow, pressure loss, energy balance, mass balance, turbine inlet temperature |
| Characteristic maps | Corrected speed, pressure or expansion ratio, flow output, efficiency output, range limits |

If a loop cannot be traced from inputs to state update and back to a map or component equation, treat it as unresolved.

## Example Evidence Patterns

The following patterns are valid evidence in a three-shaft dynamic Simulink model:

- A volume module implements `dP/dt = R*T*(G_in - G_out)/V`, with the integrator initial pressure traced to the design point.
- A rotor module computes speed derivative from turbine work minus compressor or load work, inertia, and current speed, then feeds the speed back to compressor or turbine maps.
- A compressor map wrapper uses normalized shaft speed and pressure ratio to produce relative or corrected flow and efficiency, then applies pressure/temperature correction and saturation.
- A turbine map wrapper uses normalized shaft speed and expansion ratio to produce corrected gas flow and efficiency, then applies upstream pressure and temperature correction.

## Audit Output

Return a short audit with:

- Artifact list.
- Main subsystem and loop map.
- Dynamic-state table.
- Initial-condition sources.
- Characteristic-map sources and fitted model variables.
- Missing evidence or risks.
- Next safe edit or validation step.

## Audit Table Templates

Dynamic state table:

| State | Block ID/path | Block type | Initial value | IC source | Feedback destination | Zero-derivative check |
| --- | --- | --- | --- | --- | --- | --- |

Map wrapper table:

| Component | Map block | Inputs | Outputs | Normalization | Saturation/range | Rated-point check |
| --- | --- | --- | --- | --- | --- | --- |

Rotor/volume loop table:

| Loop | State | Upstream inputs | Downstream outputs | Residual equation | Expected rated residual |
| --- | --- | --- | --- | --- | --- |
