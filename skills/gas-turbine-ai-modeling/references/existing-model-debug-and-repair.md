# Existing Model Debug and Repair

## Purpose

Use this reference when an existing gas turbine Simulink model cannot simulate, reports `NaN`/`Inf`, fails at an integrator, or becomes nonphysical during a dynamic run.

The repair objective is not merely to make the model run longer. The objective is to locate the first physical inconsistency, repair the causal source, and verify the fixed copy over short and long simulations.

## Work on Evidence, Not the Reported Error Block

The block named in a solver error is often where the failure becomes visible, not where it begins. For gas turbine dynamic models, a downstream rotor integrator may fail because an upstream volume pressure, mass flow, map output, or fuel signal has already become nonphysical.

When a model fails:

1. Reproduce the failure time and record the exact message.
2. Record the reported error block, but do not assume it is the root cause.
3. Log or inspect the earliest `NaN`, `Inf`, negative pressure, negative temperature, negative flow, invalid pressure ratio, invalid shaft speed, or invalid map-domain signal.
4. Trace two to four signal layers upstream from the reported block.
5. Classify the first causal fault before editing: equation structure, initial condition, map validity, unit conversion, controller/load input, solver setting, or numerical protection.

Do not start by adding `Saturation`, `min`, `max`, `eps`, or a protective denominator at the reported block. Numerical guards may be needed later, but they are not evidence of a physical repair.

## Repair Workflow

Use this sequence for existing `.slx` repair tasks:

1. Save or simulate a copy when possible. Do not overwrite the user's original model until the repair is confirmed.
2. Reproduce the failure with the original model and record stop time, solver, step size, inputs, and failure block.
3. Enable signal logging, Simulation Data Inspector, model instrumentation, or targeted scopes for pressure, temperature, flow, shaft speed, fuel, map outputs, and map validity.
4. Find the first nonphysical signal, not just the final block that throws the error.
5. Inspect the upstream subsystem equations and all stateful blocks feeding the signal.
6. Make a temporary unsaved edit or scratch-copy experiment to test the suspected cause.
7. If the experiment works, implement the smallest physical fix in a named fixed copy.
8. Run staged validation and record residuals and long-run checks before reporting success.

If a temporary edit improves the failure time but leaves the first nonphysical signal unchanged, it is not a root-cause fix.

## Volume Pressure Dynamics Check

Volume modules are a high-risk area in gas turbine dynamic models. The basic pressure state should be driven by instantaneous mass-flow mismatch:

```text
dP/dt = R * T * (m_in - m_out) / V
```

The flow mismatch itself should not be integrated once and then used as the input to pressure integration. That creates a nonphysical double integration.

| Pattern | Status | Reason |
| --- | --- | --- |
| `dP/dt = R*T*(m_in - m_out)/V` | Correct baseline | Pressure derivative responds to instantaneous mass imbalance. |
| `mass_error_integral = integral(m_in - m_out)` then `dP/dt = R*T*mass_error_integral/V` | Suspect or wrong | The pressure state is driven by accumulated mass-error history rather than current flow mismatch. |

Before changing a volume model, define:

- The control volume represented by the pressure state.
- The pressure unit used by the integrator.
- The temperature used in the gas law.
- The gas constant and units.
- The volume value.
- The upstream and downstream flow signals.
- Whether pressure losses are modeled outside the volume equation.

After changing a volume equation, check the rated initial derivative. If `dP/dt` is not close to zero at the intended steady point, enter trim and initialization rather than hiding the residual.

## Stateful Block Initial-Condition Audit

When debugging failures, audit every stateful block in the causal path, including:

- `Memory`
- `Delay`
- `Unit Delay`
- `Integrator`
- `Discrete-Time Integrator`
- `Transfer Fcn`
- `Discrete Transfer Fcn`
- `Transport Delay`
- Stateful MATLAB Function blocks
- Stateful map wrappers or controller states

A wrong `Memory` or delay initial condition can create a false first-step pulse in `m_in - m_out`, fuel flow, pressure ratio, or map input. Do not audit only visible integrators.

For each block in the causal path, compare:

- Block initial output at `t = 0`.
- The physical signal value expected from the design point or trim point.
- The first-step output after one solver step.
- The downstream residual produced by that value.

Default zero, inherited sample time, or old tuned values are not evidence. If a `Memory` initial condition is nonzero, verify that it represents the previous-step value of the same physical signal, not an unrelated state or an old tuning artifact.

## Earlier Failure After Formula Correction

A theoretically correct equation can make the model fail earlier if the previous wrong structure was masking a large initial residual. For example, replacing a double-integrated volume pressure structure with the instantaneous flow-mismatch equation may reveal that the initial flows, pressures, map points, or `Memory` states are inconsistent.

Do not revert to the old equation only because the corrected model fails sooner. Instead:

1. Confirm the corrected equation units and signal meanings.
2. Check rated residuals for volume pressure, shaft power, and combustor energy.
3. Audit Memory/Delay/Integrator initial conditions in the affected loop.
4. Run trim or steady initialization to obtain a consistent operating point.

Only reject the corrected equation if its source, units, or control-volume definition is wrong.

## Numerical Protection Rule

Saturation, lower bounds, epsilon denominators, and finite checks are boundary protections. They can prevent a solver crash, but they do not prove the plant is physically correct.

Use numerical protection only after:

- The causal physical fault has been identified or explicitly marked unresolved.
- The protected variable has a physical bound and unit.
- The protection does not hide map invalidity, negative pressure, negative temperature, or wrong pressure-ratio direction.
- The validation report states whether the protection was active.

## Repair Verification Ladder

For repair tasks, a short run is only a smoke test. Use staged duration extension:

```text
0.01 s -> 1 s -> 10 s -> 50 s -> default StopTime or required long run
```

At each stage, check:

- First nonphysical signal, if any.
- `NaN`/`Inf` occurrence.
- Pressure, temperature, flow, and shaft speed physical bounds.
- Rotor acceleration and volume pressure derivative near steady operation.
- Map validity and saturation activity.
- Controller or load signal limits.

For a claimed repair, also inspect a final window of the long run, such as the final 10 seconds or a project-appropriate segment. Report slow drift in shaft speeds, volume pressures, temperatures, fuel, and load variables.

## Synthetic Regression Case

This regression case is a public synthetic repair example. Treat the numbers as evidence for the example case, not universal gas turbine data.

Observed failure:

- Original model failed near `20.393 s`.
- Reported block was `PT_shaft/Integrator`.
- The downstream failure was caused by upstream pressure dynamics driving pressure toward a nonphysical value.

Root causes:

- Two volume pressure modules used a double-integrated flow-mismatch structure.
- A `Memory` initial condition near `86.7` created a false initial pulse in the mass-flow residual path.

Physical repair:

- Change the two volume pressure dynamics so instantaneous `m_in - m_out` drives `dP/dt`.
- Correct the related `Memory` initial condition to the design-point or trim-consistent previous-step signal value.
- Recheck pressure derivatives and rotor power balance.

Validation target:

- Fixed copy runs a long simulation, such as `500 s`, with no `NaN`/`Inf`.
- Key pressures, temperatures, flows, shaft speeds, and map-valid signals remain physical.
- The final-window drift check is reported.
