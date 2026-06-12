# Gas Property and Combustion

## Purpose

Gas turbine model accuracy depends strongly on the working-fluid and combustion assumptions. Do not mix constant heat capacity, variable heat capacity, gas composition, and empirical fuel-air formulas without documenting the choice.

## Property Model Levels

Choose the simplest level that satisfies the task:

| Level | Use when | Required documentation |
| --- | --- | --- |
| Constant heat capacity | Educational or early structure model | `cp`, `gamma`, `R`, temperature range, expected error |
| Temperature-dependent heat capacity | Design-point and off-design thermal accuracy matters | Formula, integration method, temperature range |
| Gas composition model | Fuel-air ratio, excess air, or emissions-sensitive behavior matters | Species set, mixture rule, fuel composition |
| NASA polynomial or database properties | High-fidelity combustion gas properties are needed | Coefficients, source, valid temperature range |
| Empirical property fit | Matching an existing model or test data | Source data, fit range, error |

Mark a model as reduced if its property level cannot support the requested accuracy.

## Air and Combustion Gas Separation

Track whether each component uses air or combustion gas:

- Compressors normally use air properties.
- Combustor outlet and turbines normally use combustion-gas properties.
- Cooling and bleed flows may start as air and mix with combustion gas.
- Gas constant and heat capacity can change after fuel addition and mixing.

Do not reuse compressor air heat capacity in turbine gas calculations unless the simplification is explicit.

## Fuel and Combustion Inputs

Record:

- Fuel type or assumed composition.
- Lower heating value.
- Combustion efficiency.
- Theoretical air-fuel ratio or stoichiometric air requirement.
- Excess-air coefficient or fuel-air ratio relation.
- Whether fuel mass is included in turbine gas flow.
- Whether heat loss is included.

If these are missing, ask the user or perform literature/source research. Do not invent fuel data silently.

## Nonstandard Fuel Or Cycle Research Branch

If the user specifies a fuel or cycle outside simplified conventional liquid-fuel or natural-gas Brayton assumptions, stop and create a formula/source research task before coding.

Examples that require research or user-provided evidence:

- hydrogen, ammonia, methanol, biofuel, blended fuel, or uncertain fuel composition;
- wet air, humid inlet, exhaust gas recirculation, or steam/water injection;
- recuperated, reheated, intercooled, or chemically unusual cycles;
- emissions-sensitive combustion or dissociation effects;
- publication-grade variable-property modeling.

Record at least:

- fuel composition or surrogate formula;
- lower heating value and source;
- stoichiometric air requirement and source;
- combustion efficiency assumption;
- gas species set or property database;
- `cp`, enthalpy, and gas-constant method;
- valid temperature and equivalence-ratio range.

If no source is available, label the model as exploratory or reduced. Do not write guessed fuel properties as facts.

## Working-Fluid Decision Gate

Before writing compressor, combustor, or turbine equations, choose and record one property path:

| Path | Minimum use case | Required user/source inputs | Do not use when |
| --- | --- | --- | --- |
| Constant `cp`, `gamma`, `R` air/gas | Concept model, control-structure prototype, early Simulink wiring | Air `cp`, gas `cp`, `gamma_air`, `gamma_gas`, `R_air`, `R_gas`, valid temperature range | The task asks for accurate design-point fuel flow, cooled turbines, or wide off-design operation |
| Temperature-dependent `cp(T)` | Design-point solver, rated-state table, moderate off-design accuracy | Formula or coefficients for air and combustion gas, integration range, average-`cp` method | Gas composition or fuel-air ratio changes dominate the requested accuracy |
| Mixture `cp`/`R` from excess air | Combustor fuel-air iteration, cooled/bleed turbine flow, changing gas composition | Fuel type, stoichiometric air requirement, excess-air coefficient or fuel-air ratio, species mixture rule | Species data or fuel assumptions are unavailable and cannot be researched |
| NASA polynomial or property database | High-fidelity cycle or publication-grade property modeling | Species set, polynomial/database source, valid temperature intervals, enthalpy reference | The implementation must stay simple and no source coefficients are available |
| Empirical project fit | Matching an existing user model or test data | User formula/data source, fit range, residual, design-point check | Extrapolation outside the fitted range is required |

If the user has supplied a validated MATLAB/Simulink property model, use it as project evidence first. Use generic constant-property equations only as a reduced fallback and label the model accordingly.

## Required Property Card

For every model variant, fill this card before coding:

| Item | Required content |
| --- | --- |
| Air property model | `cp_air`, `gamma_air`, `R_air`, or `cp_air(T)` source |
| Combustion-gas property model | `cp_gas`, `gamma_gas`, `R_gas`, or mixture/source formula |
| Fuel model | fuel name/composition, LHV, stoichiometric air requirement |
| Combustion assumptions | combustion efficiency, heat loss, pressure loss, whether fuel mass enters turbine flow |
| Cooling/bleed assumptions | source station, injection station, mass-flow rule, mixture property update |
| Units | temperature, pressure, heat value, mass flow, specific heat, gas constant |
| Valid range | temperature, fuel-air ratio, excess air, map operating range if coupled |
| Validation target | fuel flow, turbine inlet temperature, exhaust temperature, gas constant, or user reference output |

If any row is unknown, mark it as `missing` and ask for it or research it before implementing a high-fidelity formula.

## Fuel-Air Ratio From Energy Balance

A common design-point pattern is to solve fuel-air ratio from combustor energy balance:

```text
air enthalpy in + combustion heat release = combustion gas enthalpy out
```

With simplified constant heat capacities, this may become an algebraic equation. With temperature-dependent properties or gas composition, it may require iteration.

For each implementation, document:

- Unknown solved variable, such as fuel-air ratio or turbine inlet temperature.
- Initial guess.
- Iteration tolerance.
- Heat-capacity or enthalpy evaluation method.
- Convergence result.

## Combustor Formula Selection

Select the combustor relation by fidelity:

| Fidelity | Formula pattern | Dynamic-model interface |
| --- | --- | --- |
| Steady constant-property | Solve `G_air*cp_air*T_in + eta_b*G_fuel*Hu = G_gas*cp_gas*T_out` | Inputs: `G_air`, `T_in`, `G_fuel`; outputs: `T_out`, `G_gas`, `P_out` |
| Steady variable-`cp` | Replace `cp*T` with enthalpy or average-`cp` integration | Include iterative solver state or MATLAB Function convergence evidence |
| Excess-air iteration | Solve fuel-air ratio and excess-air coefficient together from energy and stoichiometry | Record `gf`, `alpha`, `Lo`, convergence tolerance, initial guess |
| Cooled combustor/turbine inlet | Add cooling/dilution mass and energy terms before turbine inlet | Output cooling/mixing bus or explicit `gco*`, `betat*`, `acc` signals |
| Dynamic combustor | Add pressure, temperature, fuel-actuator, or thermal lag state | Register every state block initial condition and check `dP/dt`/`dT/dt` at trim |

Never mix a variable-`cp` design-point solver with a constant-`cp` dynamic combustor without documenting the intended reduction and expected mismatch at the rated point.

## Design Temperature Versus Protection Temperature

Do not treat a design-point combustor outlet or turbine inlet temperature as the only temperature limit.

Record separate values when the task involves control, protection, or transient simulation:

| Variable | Meaning |
| --- | --- |
| `T3_design` | rated design-point combustor outlet or turbine inlet temperature |
| `T3_continuous_limit` | continuous operating limit |
| `T3_transient_limit` | short-duration transient limit |
| `T3_trip_limit` | shutdown or trip threshold |
| `T3_control_margin` | margin used by controller or fuel limiter |

If only `T3_design` is known, ask whether it is a design target, a continuous limit, a transient limit, or a trip limit. Do not automatically clamp the dynamic model at the design temperature unless the user confirms that control assumption.

## Variable Heat Capacity

If using average heat capacity over a temperature range, document:

```text
cp_avg = integral(cp(T), T_low, T_high) / (T_high - T_low)
```

For Simulink conversion, avoid hiding this as an unexplained algebraic loop. Use a documented feedback or MATLAB Function implementation with initial values and convergence checks.

## Cooling and Mixing Properties

Cooling air mixed into hot gas changes:

- Mass flow.
- Mixture temperature.
- Heat capacity.
- Gas constant.
- Turbine work.
- Pressure loss if mixing loss is modeled.

At each mixing point, identify whether mixture properties are recalculated or approximated.

## Combustion Model Evidence

Before implementing combustion formulas, prepare:

| Item | Evidence |
| --- | --- |
| Fuel data | Source and value |
| Air-fuel relation | Formula and source |
| Heat release | Lower heating value and efficiency |
| Gas properties | Constant, variable, mixture, or polynomial source |
| Cooling/mixing | Flow source and destination |
| Validation | Turbine inlet temperature, fuel flow, or exhaust temperature comparison |
