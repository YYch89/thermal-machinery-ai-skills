# Validation Checklist

## Design-Point Checks

Verify:

- Compressor outlet pressures increase in the correct order.
- Compressor outlet temperatures increase in the correct order.
- Combustor pressure is lower than compressor outlet pressure after pressure loss.
- Turbine temperatures and pressures decrease through expansion.
- Fuel-air ratio and excess-air coefficient are physically plausible.
- Cooling or bleed flow coefficients are nonnegative and bounded.
- Component powers satisfy shaft work balance.
- Rated air flow back-calculates the requested rated power.

Before reporting a gas-turbine model as validated, record the evidence type and check at minimum:

- total mass balance across inlet, compressor path, cooling/bleed, combustor, turbine path, and exhaust;
- fuel/air/species or element balance where combustion composition is modeled;
- component and whole-system energy balance;
- pressure-path consistency through inlet, compressors, combustor, turbines, ducts, heat exchangers, and exhaust;
- map-domain validity for compressor and turbine maps;
- dynamic initialization residuals for rotor, volume, combustor, actuator, and controller states when dynamics are present.

A design-point comparison, a dynamic run, and an experimental/calibration comparison are different evidence levels. State the evidence level instead of using a bare `validated` label.

## MATLAB vs Simulink Design-Point Checks

Compare:

- State-point pressures.
- State-point temperatures.
- Air flow and fuel flow.
- Component work values.
- Cooling flow coefficients.
- Fuel-air ratio or excess-air coefficient.
- Thermal efficiency and specific fuel consumption.

Use tolerances appropriate to heat-capacity and solver differences. If Simulink uses feedback with memory, ensure the model reaches the same settled value, not just the same initial value.

## Steady-State Checks

At rated air flow and fuel flow, the steady-state model should reproduce the design-point outputs within declared tolerance.

For off-design steady cases:

- Increasing fuel flow should generally increase turbine inlet temperature and power unless limited.
- Increasing air flow at fixed fuel may reduce fuel-air ratio and change turbine inlet temperature.
- Power balance should remain physically interpretable.
- No pressure ratio should become negative or cross an impossible direction.

## Dynamic Checks

Before running dynamic validation, verify that an iteration map and initial-condition registry exist.

Declare validation tolerances before judging results. At minimum, specify tolerances for pressure, temperature, mass flow, power, shaft acceleration, pressure derivative, and map fitting error. Use project requirements if available; otherwise state temporary engineering tolerances and mark them as assumptions.

At initial design-point conditions:

- Rotor accelerations should be near zero if load and fuel match the design point.
- Volume pressure derivatives should be near zero if component flows match.
- Combustor temperature derivative should be near zero if fuel and air match.
- Compressor and turbine map operating points should lie within valid ranges.

For transients:

- Fuel increase should produce a delayed temperature and power response.
- Shaft speeds should change according to power imbalance.
- Volume pressures should respond to flow mismatch.
- Surge margin should be monitored when compressor maps are used.
- Saturation blocks should be checked to ensure they do not hide invalid map operation.

## Simulation Duration Gate

Do not validate a dynamic model using only a short simulation.

For repair of an existing model that previously failed, use a staged duration ladder when practical:

```text
0.01 s -> 1 s -> 10 s -> 50 s -> default StopTime or required long run
```

The repair is not complete until the fixed copy passes beyond the original failure time and the long-run final window has been checked for drift and nonphysical signals.

Use at least three time scales when practical:

| Run | Purpose | Required checks |
| --- | --- | --- |
| Short run | Initial response and sign checks | state derivatives, power imbalance signs, pressure direction, controller polarity |
| Medium run | Settling behavior after perturbation | speed, pressure, temperature, fuel, actuator saturation, map validity |
| Long run | Slow drift and hidden instability | last-window slope of shaft speed, pressure, temperature, fuel, and load variables |

For long runs, inspect at least the final window, such as the final 10 seconds or a project-appropriate final segment:

- Shaft speeds should not drift unless commanded or physically explained.
- Volume pressures should not drift under a constant operating condition.
- Turbine inlet and exhaust temperatures should not slowly diverge.
- Fuel flow should not walk into a limiter at a steady command.
- `map_valid`, surge margin, or equivalent operating-domain indicators should remain valid.
- No pressure, temperature, flow, or shaft speed should become nonphysical.

If a short run passes but a long run fails, treat the model as not validated. Diagnose plant residuals, map validity, and initial conditions before retuning the controller.

## Characteristic Map Checks

For every fitted compressor or turbine map, verify:

- Input features are named and normalized.
- Output target is named and normalized.
- Design-point operating value lies inside the fitted range.
- The fitted map reproduces source points within a documented error.
- Saturation or fallback behavior is defined outside the fitted range.
- Compressor surge boundary or surge margin logic is present when available.

When map validity signals exist, log them through the full simulation. Passing the rated point is not enough if load steps or long holds leave the valid domain.

## Traceability Evidence

For each validation run, record:

- Model version or file.
- Initial conditions.
- Inputs.
- Solver and step size.
- Key outputs.
- Difference against design point or baseline.
- Any manually tuned values.

## Tolerance Declaration Template

Use a table like this before reporting pass/fail:

| Quantity | Tolerance | Basis |
| --- | --- | --- |
| Pressure state | e.g. relative error or absolute Pa/MPa limit | design-point comparison or project requirement |
| Temperature state | e.g. K or relative error | design-point comparison or project requirement |
| Mass flow | e.g. kg/s or relative error | flow balance |
| Component power | e.g. kW or relative error | shaft work balance |
| Shaft acceleration | e.g. rpm/s near rated initialization | rotor equilibrium |
| Volume pressure derivative | e.g. Pa/s or MPa/s near rated initialization | mass balance |
| Map fit | e.g. MSE or relative error | fitting validation |

Do not use phrases such as "near zero" or "reasonable" without a declared tolerance.

## Default Tolerance Starting Points

Use project, test, or literature tolerances when available. If none are available, these are starting points for an exploratory engineering check, not universal pass criteria:

| Quantity | Initial suggested tolerance |
| --- | --- |
| Design-point pressure | 0.5% to 2% relative error |
| Design-point temperature | 1 K to 5 K, or 0.5% to 1% relative error |
| Air or gas mass flow | 0.5% to 2% relative error |
| Fuel flow | 0.5% to 2% relative error |
| Component power/work | 1% to 3% relative error |
| Shaft power balance at rated trim | less than 0.5% to 1% of rated shaft power |
| Initial shaft acceleration | choose a small rpm/s threshold consistent with simulation time scale |
| Initial volume pressure derivative | choose a small Pa/s or MPa/s threshold consistent with volume and pressure units |
| Combustor energy residual | less than 1% to 3% of heat-release or gas enthalpy flow |
| Map fitting error near design point | tighter than global map error; declare MSE or relative error |

When using these starting points, label them as assumptions and ask the user to confirm or revise them at the validation gate.

## Loop-by-Loop Validation Evidence

For dynamic model validation, include one row per feedback loop:

| Loop | Initial derivative or acceleration | Expected value | Pass/fail | Evidence signal |
| --- | --- | --- | --- | --- |
| Low-pressure shaft | dN_L/dt | near zero at rated point |  |  |
| High-pressure shaft | dN_H/dt | near zero at rated point |  |  |
| Power shaft | dN_P/dt | near zero when load matches turbine power |  |  |
| Compressor volume | dP/dt | near zero when flows match |  |  |
| Turbine volume | dP/dt | near zero when flows match |  |  |
| Combustor | dT/dt or mass residual | near zero at rated fuel/air |  |  |

Do not treat a successful long simulation as sufficient validation if the loop residuals are not checked.

## Scenario Matrix Checks

For controls or operational studies, validate more than one case:

- Rated initial condition.
- Load unload or rejection.
- Load step-up.
- Fuel step independent of controller.
- Speed command change.
- Several steady load levels.
- Near-map-boundary case.
- Long hold at a representative operating point.

For each scenario, report whether any nonphysical state, saturation, invalid map lookup, or slow drift occurred.
