# Source Provenance and Toolkit Integration

## Purpose

This public skill combines project-specific modeling evidence, generic gas turbine equation templates, and external MATLAB/Simulink agentic tooling. Keep these sources distinct when using or reviewing the skill.

## Project-Specific Evidence

When applying this skill to a real gas-turbine project, prefer the active project artifacts over generic templates. Typical project artifacts include:

- design-point MATLAB scripts;
- design-point Simulink conversion models;
- steady-state transition models;
- dynamic three-shaft Simulink models;
- dynamic iteration-flow diagrams describing volume, rotor, combustor, compressor-map, and turbine-map feedback loops;
- compressor and turbine characteristic-map fitting scripts, including lookup-table, polynomial, neural-network, or GA-BP fitting patterns.

Rules that must be preserved when such materials exist include:

- Build sequence: design point -> Simulink design point -> steady thermodynamic plant -> dynamic plant -> controller.
- Dynamic model emphasis on volume pressure loops, shaft power-balance loops, combustor response, and map-based flow.
- Requirement that `Memory`, `Unit Delay`, integrators, transfer functions, and other feedback state blocks have explicit initial values.
- Use of design-point results as initial values, normalization references, and rated validation targets.
- Treatment of compressor/turbine maps as dynamic flow and efficiency providers rather than fixed design-point flow constants.

For a public placeholder example of expected artifacts, read `sample-three-shaft-case.md`. It contains:

- design-point to dynamic mapping examples;
- loop-contract examples for rotor and volume states;
- validation-report examples;
- user-confirmation gate examples.

## Generic Templates

Files such as `component-equation-templates.md`, `gas-property-and-combustion.md`, and `equations-and-units.md` contain generic engineering templates and documentation requirements. They are not a line-by-line extraction of the user's MATLAB code.

Use them as:

- Checklists for required inputs, outputs, units, assumptions, and residuals.
- Starting templates when the user has not provided a formula.
- Prompts for literature or source research.

Do not treat them as the only correct equations for every gas turbine. When project code, textbooks, papers, or validated project formulas differ, use the confirmed source and record the difference.

## Formula Provenance Rule

Before implementing a formula, identify it as one of:

| Provenance | How to use |
| --- | --- |
| Project model derived | Cite the project file/model and verify against its outputs |
| Literature or source derived | Cite the source and applicability |
| Open-source implementation derived | Cite repository, license if copying code, equations, assumptions, and tests |
| Generic template | Mark as a starting assumption until confirmed |
| Tuned or empirical | Record fit data, valid range, and residuals |

Do not blur these categories in reports.

## Toolkit Skills To Reuse

Use these MathWorks Simulink Agentic Toolkit skills alongside this domain skill when available:

- `specifying-plant-models`: write plant model system, architecture, implementation, and validation specifications before building.
- `building-simulink-models`: make scoped Simulink edits with `model_read` and `model_edit`.
- `simulating-simulink-models`: run exploratory simulations with `SimulationInput` and analyze logged results.
- `testing-simulink-models`: create persistent pass/fail Gherkin tests with `model_test` when Simulink Test is available.
- `specifying-mbd-algorithms`: specify controller or model-based design algorithms.
- `generate-requirement-drafts`: draft requirements from existing models when traceability is needed.
- `filing-bug-reports`: produce reproducible bug reports for toolkit or model issues.

Use MATLAB Agentic Toolkit skills when working on MATLAB code:

- `matlab-review-code`: static and style review.
- `matlab-debugging`: diagnose MATLAB execution errors.
- `matlab-testing`: create or run MATLAB unit tests.
- `matlab-modernize-code`: note deprecated MATLAB patterns when modernization is requested.

If direct Simulink MCP calls fail because the running MATLAB session is not shared, do not abandon structured inspection. Try this fallback sequence:

1. Run `satk_initialize` in MATLAB.
2. Confirm `which('model_overview')` and `which('model_read')` return the Simulink Agentic Toolkit tool paths.
3. Use MATLAB batch or an existing MATLAB session to call `model_overview` and `model_read`.
4. Use Simulink API calls such as `Simulink.ID.getFullName` and `get_param` for targeted read-only parameter extraction.
5. Record the MCP/tool limitation in the audit notes.

## GitHub Resources Worth Referencing

Useful public repositories and references include:

- `openai/skills`: official Codex skills catalog and examples for skill structure.
- `matlab/simulink-agentic-toolkit`: Simulink Agentic Toolkit, MCP tools, and model-based-design skills.
- `matlab/matlab-agentic-toolkit`: MATLAB MCP Core Server setup and curated MATLAB skills.

Do not vendor or copy external skill text blindly. Prefer linking to the installed toolkit skill by name and using its workflow when the task triggers it.

## Integration Rule

This skill supplies gas-turbine domain workflow. The MathWorks toolkits supply MATLAB/Simulink execution workflows. Use both:

1. Use this skill to decide what model should be built, what evidence is required, and what validation gates apply.
2. Use MATLAB MCP and Simulink Agentic Toolkit tools to inspect, edit, simulate, test, and verify the actual files.
