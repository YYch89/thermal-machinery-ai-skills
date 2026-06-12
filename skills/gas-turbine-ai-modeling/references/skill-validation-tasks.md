# Skill Validation Tasks

## Purpose

Use this file to test whether an AI agent actually follows this skill when building, inspecting, or planning gas turbine MATLAB/Simulink models.

This is a validation aid, not a modeling reference. Do not load it during ordinary model building unless the task is to test, audit, or externally review the skill itself.

## Validation Rule

For blind validation, give the evaluator only:

- `SKILL.md`
- The task prompt being tested
- Any source files explicitly named in the prompt
- The minimum reference files that `SKILL.md` tells the evaluator to load

Do not give the evaluator the expected answer, known failure modes, prior critique, or conclusions unless the goal is a non-blind review.

## Scoring Rubric

Score each dimension from 0 to 3.

| Dimension | 0 | 1 | 2 | 3 |
| --- | --- | --- | --- | --- |
| Scope triage | Assumes architecture/application | Mentions scope but does not ask or resolve key gaps | Identifies most scope variables | Clearly separates application, architecture, working fluid, fidelity, and control target |
| Staged workflow | Jumps to dynamic/control model | Mentions stages but skips gates | Uses staged order with minor gaps | Enforces design point -> Simulink design point -> steady plant -> dynamic plant -> control |
| Formula provenance | Invents formulas or hides assumptions | Lists formulas without sources | Marks user/literature/template assumptions | Gives formula source, applicability, variables, units, and validation plan |
| MATLAB/Simulink tool use | Treats files as drawings/text only | Uses generic file reading | Uses MATLAB or Simulink tools partially | Uses MATLAB MCP/SATK or documented fallback to inspect executable model structure |
| Dynamic-loop handling | Ignores feedback loops | Names loops vaguely | Identifies volume/rotor/map loops | Produces loop contracts, state variables, feedback paths, and build order |
| Initial conditions | Ignores ICs | Mentions ICs generally | Lists key ICs | Builds an initial-condition registry with source, block, state, and zero-derivative checks |
| Characteristic maps | Uses fixed design flow in dynamics | Mentions maps without range/checks | Uses map inputs/outputs | Documents map data, fitting method, normalization, saturation, residuals, and operating range |
| Validation gates | No verification | Generic "run simulation" | Stage-level checks | Quantitative checks, user confirmation gates, and failure handling |
| Control integration | Adds controller immediately | Mentions controller but mixes plant/control | Adds control after plant validation | Separates generation/propulsion/mechanical-drive control objectives and protects open-loop plant validation |
| Output auditability | Unstructured prose | Some tables | Mostly auditable artifacts | State table, assumptions, mapping table, loop registry, IC registry, validation report |

Suggested pass threshold:

- Minimum acceptable: total score at least 22/30, no dimension scored 0.
- Strong pass: total score at least 26/30, no dimension below 2.
- If any of staged workflow, tool use, dynamic-loop handling, or initial conditions scores 0, the skill failed for complex dynamic modeling.

## Task 1: Existing Dynamic Model Audit

Prompt:

```text
Use the gas turbine AI modeling skill to audit `example_three_shaft_dynamic.slx`.
Do not modify the model. I want to know whether the dynamic model is structured correctly.
Focus on dynamic iteration loops, volume modules, rotor modules, combustor dynamics, characteristic maps, and initial conditions.
Use MATLAB/Simulink tools where available.
```

Expected behavior:

- Load `model-evidence-audit.md`, `sample-three-shaft-case.md`, `dynamic-iteration-map.md`, `dynamic-loop-build-protocol.md`, `initial-condition-registry.md`, `characteristic-map-fitting.md`, and `validation-checklist.md` as needed.
- Use `model_overview` and `model_read`, or document a MATLAB/SATK fallback.
- Identify top-level architecture: compressor modules, combustor, three turbine modules, three rotor modules, and volume modules.
- Produce loop contracts for at least:
  - low-to-high compressor volume,
  - high-to-low turbine volume,
  - low-to-power turbine volume,
  - low-pressure rotor,
  - high-pressure rotor,
  - power rotor,
  - combustor pressure/temperature behavior,
  - compressor/turbine map feedback.
- Extract or request initial conditions for integrators, Unit Delay, Memory, Transfer Fcn, and Transport Delay blocks.
- Do not claim the model is validated until simulation or residual checks are performed.

Common failures:

- If the agent only describes subsystem names, strengthen `model-evidence-audit.md`.
- If it misses initial values, strengthen `initial-condition-registry.md`.
- If it does not mention maps, strengthen `characteristic-map-fitting.md` and `dynamic-modeling.md`.

## Task 2: New Three-Shaft Generation Plant Plan

Prompt:

```text
I want to build a dynamic MATLAB/Simulink model for a three-shaft gas turbine used for power generation.
Rated power is 21 MW, total pressure ratio is about 23.5, turbine inlet temperature is 1550 K.
I want the model to eventually control power turbine speed.
Please tell me the modeling workflow and what you need from me before you start building.
```

Expected behavior:

- Ask for or list missing requirements before building:
  - fuel and LHV,
  - ambient condition,
  - compressor/turbine efficiencies,
  - pressure losses,
  - shaft speeds and inertias,
  - cooling/bleed assumptions,
  - working-fluid/property model,
  - compressor/turbine maps,
  - volume estimates,
  - load/generator model,
  - control objective and operating envelope.
- State that the design-point solver must come before dynamic modeling.
- Use the staged workflow and stage gates.
- Separate open-loop plant validation from controller integration.
- Explain that power-turbine speed control is reasonable for generation, but only after open-loop plant initialization and trim checks.
- Produce expected deliverables: design-point table, Simulink design-point model, steady input-output plant, dynamic loop map, IC registry, validation report, control integration plan.

Common failures:

- If the agent jumps directly to controller design, strengthen `control-integration.md`.
- If it fails to ask about application or fuel/gas properties, strengthen `requirements-and-scope-triage.md` and `gas-property-and-combustion.md`.
- If it skips stage gates, strengthen `stage-gates-user-confirmation.md`.

## Task 3: Propulsion Versus Generation Trap

Prompt:

```text
Build a dynamic gas turbine model. It might be for propulsion, not power generation.
I have not decided the exact gas turbine architecture yet.
Please start by giving the modeling plan.
```

Expected behavior:

- Do not assume a three-shaft free power turbine unless the user confirms it.
- Ask one concise question at a time if interaction is allowed, or list the blocking decisions if producing a read-only plan.
- Distinguish generation, propulsion, and mechanical-drive boundary conditions.
- Explain that controller choice changes with application:
  - generation may prioritize power turbine/generator speed or power,
  - propulsion may prioritize thrust, gas-generator speed, exhaust temperature, surge margin, or nozzle/propulsor coupling,
  - mechanical drive may prioritize load torque/speed.
- Avoid detailed formulas until architecture, working fluid, and fidelity are selected.

Common failures:

- If the agent forces the three-shaft generation workflow, strengthen `requirements-and-scope-triage.md`.
- If it adds a power turbine speed controller by default, strengthen `control-integration.md`.

## Task 4: Formula Provenance Challenge

Prompt:

```text
I do not have a formula source for the combustor and turbine modules.
Please decide formulas for a gas turbine thermodynamic model and explain how you would implement them in MATLAB/Simulink.
```

Expected behavior:

- Refuse to invent untraceable equations.
- Ask for target architecture, fuel, working-fluid assumptions, and fidelity.
- Use `literature-and-formula-evidence.md`, `component-equation-templates.md`, `gas-property-and-combustion.md`, and `equations-and-units.md`.
- Provide candidate formula families with source category and applicability.
- Mark formulas as user-derived, literature-derived, open-source-derived, generic template, or assumption.
- Require user confirmation before coding formulas into the model.

Common failures:

- If the agent writes formulas without source categories, strengthen `literature-and-formula-evidence.md`.
- If it ignores gas properties, strengthen `gas-property-and-combustion.md`.

## Task 5: Characteristic Map Replacement Challenge

Prompt:

```text
The current dynamic model uses neural-network compressor and turbine maps.
Can we replace them with lookup tables or polynomial fits?
```

Expected behavior:

- Say replacement is possible only if the original data range, normalization, residuals, rated operating point, and saturation behavior are preserved or improved.
- Load `characteristic-map-fitting.md` and `sample-three-shaft-case.md` when an example artifact shape is needed.
- Require a map audit:
  - source data,
  - feature columns,
  - targets,
  - speed lines,
  - pressure/expansion ratio range,
  - flow/efficiency range,
  - design-point match,
  - extrapolation behavior.
- Explain consequences for dynamic flow matching and surge/operating-range detection.
- Require user confirmation before replacing an existing trained network in Simulink.

Common failures:

- If the agent treats the map as a cosmetic implementation detail, strengthen `off-design-matching.md` and `characteristic-map-fitting.md`.

## Task 6: Trim and Initialization Challenge

Prompt:

```text
The dynamic model starts near the design point but pressure and shaft speed drift immediately.
How should I diagnose this?
```

Expected behavior:

- Load `trim-and-initialization.md`, `initial-condition-registry.md`, `dynamic-loop-build-protocol.md`, and `validation-checklist.md`.
- Explain that design-point values may not make all dynamic derivatives zero once maps, volumes, fuel actuator, controller, and delays are added.
- Build a diagnosis plan:
  - freeze controller/load transients,
  - check map rated-point outputs,
  - compute volume flow residuals,
  - compute shaft power residuals,
  - check combustor mass/energy residuals,
  - inspect every integrator/delay IC,
  - run trim or steady-state solve if needed.
- Separate plant initialization problems from controller tuning problems.

Common failures:

- If the agent suggests PID tuning first, strengthen `trim-and-initialization.md` and `control-integration.md`.

## Task 7: Wrapper Versus Component Plant Challenge

Prompt:

```text
I have a Simulink model that runs by putting most gas turbine plant equations inside MATLAB Function blocks. Can I call this the final component-level dynamic plant?
```

Expected behavior:

- Do not call a running wrapper a final component-level plant.
- Load `model-maturity-and-delivery.md`, `simulink-staging.md`, and `deliverable-definition.md`.
- Classify the model maturity:
  - V0 MATLAB baseline,
  - V1 Simulink wrapper,
  - V2 native component plant,
  - V3 scenario-ready,
  - V4 calibrated.
- Explain that MATLAB Function/Fcn/Interpreted MATLAB Function blocks may be acceptable for V0/V1 or utilities, but final V2+ plant physics should be visible and auditable in Simulink subsystems unless the user accepts an opaque component.
- Require loop contracts, visible states, initial-condition registry, long simulation, and map validity before final delivery.

Common failures:

- If the agent says "it runs, so it is complete", strengthen `model-maturity-and-delivery.md` and `deliverable-definition.md`.

## Task 8: Scattered Map Gridding Challenge

Prompt:

```text
My compressor map data are scattered points, not a rectangular table. I want to convert them to a 2-D Lookup Table for Simulink. What should I watch out for?
```

Expected behavior:

- Load `characteristic-map-fitting.md`.
- Classify the map as scattered data, not a regular rectangular table.
- Require separate value interpolation and validity-domain logic.
- Reject nearest-neighbor filling as proof of physical validity.
- Require convex hull, speed-line envelope, alpha-shape, or `valid_table` style validity checks.
- Check design point, steady points, transient path, and long-simulation final window against map validity.
- Explain that saturation prevents numerical blow-up but does not make an invalid operating point valid.

Common failures:

- If the agent treats the gridded table as globally valid, strengthen `characteristic-map-fitting.md` and `validation-checklist.md`.

## Task 9: Existing Model NaN/Inf Repair Challenge

Prompt:

```text
Use the gas turbine AI modeling skill to repair an existing dynamic Simulink gas turbine model.
The original model fails near 20.393 s at `PT_shaft/Integrator`.
Do not just add saturation to the reported integrator. Diagnose the physical cause, make the smallest repair in a copy, and verify the result.
```

Expected behavior:

- Load `existing-model-debug-and-repair.md`, `model-evidence-audit.md`, `initial-condition-registry.md`, `dynamic-modeling.md`, `trim-and-initialization.md`, and `validation-checklist.md`.
- Reproduce and record the failure time before editing.
- Treat `PT_shaft/Integrator` as the visible failure block, not automatically the root cause.
- Trace upstream two to four signal layers and identify the first nonphysical pressure, temperature, flow, shaft-speed, or map-validity signal.
- Inspect volume pressure modules for the double-integration anti-pattern:
  - wrong: integrate `m_in - m_out`, then use that integral to drive pressure derivative,
  - baseline: `dP/dt = R*T*(m_in - m_out)/V`.
- Audit `Memory`, `Delay`, `Unit Delay`, and `Integrator` initial values in the causal path, including whether a nonzero Memory IC is a valid previous-step signal.
- Use temporary or copied-model edits first, then save a fixed copy only after evidence supports the repair.
- Run staged verification such as `0.01 s -> 1 s -> 10 s -> 50 s -> default StopTime`, and pass beyond the original failure time.
- For a strong pass, run a long simulation such as `500 s` when practical and report no `NaN`/`Inf`, no nonphysical key states, and final-window drift checks.

Common failures:

- If the agent adds saturation or lower bounds at the reported integrator first, strengthen `existing-model-debug-and-repair.md` and `common-pitfalls.md`.
- If it does not inspect Memory/Delay initial values, strengthen `initial-condition-registry.md`.
- If it claims success after a short run only, strengthen `validation-checklist.md`.

## Failure-To-Reference Map

| Failure observed | Reference to improve |
| --- | --- |
| Skips user requirement triage | `requirements-and-scope-triage.md` |
| Jumps straight to dynamic model | `three-shaft-workflow.md`, `stage-gates-user-confirmation.md` |
| Treats design point as dynamic model | `design-point-solver.md`, `simulink-staging.md`, `dynamic-modeling.md` |
| Ignores formula source | `literature-and-formula-evidence.md`, `source-provenance-and-toolkit-integration.md` |
| Uses generic equations over project code | `source-provenance-and-toolkit-integration.md`, `literature-and-formula-evidence.md` |
| Ignores map fitting/range | `characteristic-map-fitting.md`, `off-design-matching.md` |
| Ignores feedback loop order | `dynamic-iteration-map.md`, `dynamic-loop-build-protocol.md` |
| Ignores initial conditions | `initial-condition-registry.md`, `trim-and-initialization.md` |
| Adds controller before plant validation | `control-integration.md`, `trim-and-initialization.md` |
| Fails to use MATLAB/SATK tools | `source-provenance-and-toolkit-integration.md`, `model-evidence-audit.md` |
| Fixes reported error block instead of upstream physics | `existing-model-debug-and-repair.md`, `common-pitfalls.md` |
| Misses double-integrated volume pressure dynamics | `existing-model-debug-and-repair.md`, `dynamic-modeling.md` |
| Ignores Memory/Delay initial conditions in repair | `existing-model-debug-and-repair.md`, `initial-condition-registry.md` |
