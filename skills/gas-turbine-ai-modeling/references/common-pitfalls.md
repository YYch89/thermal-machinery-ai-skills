# Common Pitfalls

## Conceptual Mistakes

- Treating a three-shaft gas turbine as a single-shaft model.
- Forcing the three-shaft reference workflow onto a different gas turbine architecture without scope triage.
- Mixing up design calculation and steady-state plant calculation.
- Keeping compressor or turbine flow fixed in a dynamic model.
- Adding controller logic before the plant model is physically validated.
- Reusing a generator speed controller for a propulsion or mechanical-drive model without confirming the control objective.
- Using a first-order delay where a rotor, volume, or combustor state is required.
- Fixing the block named in a solver error before tracing the upstream physical cause.

## Equation and Unit Mistakes

- Reversing pressure ratio or expansion ratio.
- Using Celsius instead of Kelvin.
- Mixing MPa and Pa without conversion.
- Mixing kg/s and kg/h for fuel flow.
- Mixing kW and W in rotor acceleration.
- Integrating rpm with an equation derived for rad/s without conversion.
- Applying compressor efficiency as if it were turbine efficiency.
- Ignoring pressure recovery or total pressure loss.
- Losing the distinction between air heat capacity and combustion gas heat capacity.
- Treating a constant heat-capacity model as high fidelity without checking the temperature range.
- Applying a formula outside its source assumptions or map range.
- Driving a volume pressure derivative with an integrated flow residual instead of the instantaneous flow mismatch.

## Simulink Mistakes

- Copying MATLAB `while` iteration directly into block diagrams without a convergence strategy.
- Creating algebraic loops unintentionally.
- Adding `Memory` or `Unit Delay` without a design-point-based initial value.
- Auditing only `Integrator` initial conditions while ignoring `Memory`, `Delay`, `Unit Delay`, or transfer-function states.
- Adding `Unit Delay` just to remove an algebraic-loop warning without checking the physical effect.
- Adding many feedback blocks before creating an initial-condition registry.
- Building a dynamic plant without first drawing the full iteration map.
- Hiding important physics in anonymous Fcn blocks without documentation.
- Using many `Goto`/`From` tags without a tag dictionary.
- Assuming model layout reflects executable signal flow; inspect actual block connections.
- Believing a Simulink screenshot without checking ports, parameters, `Goto`/`From` tags, inherited sample times, and stateful blocks.

## Characteristic Map Mistakes

- Using design-point flow instead of map-derived flow.
- Feeding actual speed where corrected speed is required.
- Mixing relative speed with corrected speed without documenting the conversion.
- Feeding pressure ratio outside the fitted range without saturation or warning.
- Fitting a map without recording normalization constants.
- Ignoring surge margin for compressor maps.
- Training a neural-network map without preserving the source data, feature meaning, target meaning, valid range, and error metrics.
- Letting saturation hide operation outside the fitted map range.
- Adding numerical protection to hide `NaN`, `Inf`, negative pressure, or invalid pressure ratio before finding the physical root cause.

## AI-Specific Mistakes

- Inventing missing parameters instead of marking them as assumptions.
- Inventing formulas instead of researching sources or asking the user for theory support.
- Adding compatibility layers or abstractions before the physical model works.
- Refactoring unrelated model areas while trying to fix one subsystem.
- Reporting a model as validated because it runs, without comparing state points and balances.
- Reporting validation without declaring numerical tolerances.
- Using design-point initial values after adding maps and actuator states without checking trim residuals.
- Treating empirical neural-network map blocks as black boxes and failing to document inputs, outputs, and valid ranges.
- Closing compressor maps, turbine maps, volume pressures, rotor speeds, combustor dynamics, fuel actuator, and load controller in one step instead of validating one loop at a time.
