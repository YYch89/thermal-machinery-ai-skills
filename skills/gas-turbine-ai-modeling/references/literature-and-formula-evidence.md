# Literature and Formula Evidence

## Purpose

AI may research formulas, map conventions, fuel/gas properties, and control strategies when the user has not provided them. Research is allowed, but formulas must remain traceable and scoped to the user's application.

Do not invent thermodynamic, combustion, map, or control equations.

## Source Priority

Use sources in this order when available:

1. User-provided model, code, notes, PDFs, or experimental data.
2. Textbooks, engineering handbooks, standards, and official documentation.
3. Peer-reviewed papers, theses, or technical reports.
4. Validated open-source models or GitHub repositories with documented theory and tests.
5. Engineering assumptions, clearly labeled as assumptions.

When using online search, prefer primary or technically documented sources. For current tools, repositories, and papers, verify the latest source rather than relying on memory.

## Evidence Table

For every selected formula or model relation, record:

| Item | Required evidence |
| --- | --- |
| Formula name | Compressor temperature rise, combustor energy balance, turbine expansion, rotor balance, volume pressure, controller law, etc. |
| Source | User file, book, paper, repository, or assumption |
| Applicability | Single-shaft, two-shaft, three-shaft, propulsion, generator, ideal gas, variable cp, map-based, etc. |
| Variables | Meaning, unit, and sign convention |
| Required parameters | Efficiencies, losses, heat value, gas constants, inertia, volume, map normalization |
| Limitations | Valid range, missing effects, simplified chemistry, no surge model, no heat loss, etc. |
| Validation plan | How the formula will be checked in MATLAB/Simulink |

If two sources disagree, show the difference and ask the user which convention to adopt.

## Open-Source and Research Tools

AI may use literature search tools, GitHub search, repository readers, citation managers, or other research utilities when available. Their role is to collect evidence, not to bypass user confirmation.

For open-source implementations:

- Check license only if code will be copied or redistributed.
- Prefer extracting modeling ideas and references rather than copying code.
- Verify whether the repository is for design point, transient simulation, control, propulsion, or power generation.
- Check whether tests, examples, data files, or papers support the implementation.
- Record equations and assumptions in the evidence table before using them.

## Starter Source Landscape

The following sources were verified on 2026-06-09 as useful starting points. They do not replace project-specific theory selection.

| Source | Use for | Notes |
| --- | --- | --- |
| NASA Glenn, [Compressor Thermodynamics](https://www.grc.nasa.gov/www/k-12/airplane/compth.html) | Basic compressor pressure-ratio, temperature-ratio, and work relations | Good for sanity checking compressor temperature rise and efficiency convention; not enough for cooled multi-spool dynamic models |
| NASA Glenn, [Power Turbine Thermodynamics](https://www.grc.nasa.gov/WWW/K-12/VirtualAero/BottleRocket/airplane/powtrbth508.html) | Basic turbine pressure-ratio, temperature-ratio, and work relations | Good for turbine expansion and efficiency sign convention checks |
| NASA Glenn, [Compressor-Turbine Matching](https://www.grc.nasa.gov/www/k-12/VirtualAero/BottleRocket/airplane/ctmatch.html) | Shaft work matching and design/off-design distinction | Useful for explaining why turbine work must match compressor work on mechanically coupled shafts |
| NASA Glenn, [Brayton Cycle](https://www.grc.nasa.gov/www/k-12/airplane/brayton.html) | Cycle-level framing | Use only as first-principles background; it is not a detailed engineering model |
| MathWorks, [Compressor Map](https://www.mathworks.com/help/hydro/ug/Compressor-Map.html) | Dynamic compressor map table requirements | Supports the rule that dynamic compressors need pressure ratio, corrected mass flow, and efficiency tables |
| MathWorks, [Turbine (G)](https://www.mathworks.com/help/hydro/ref/turbineg.html) | Turbine map parameterization, corrected mass flow, corrected speed | Useful for map conventions and lookup-table alternatives |
| MathWorks, [Turbomachinery Examples](https://www.mathworks.com/help/hydro/gas_turbomachinery.html) | Simscape/Simulink examples and Brayton-cycle APU context | Shows a single-shaft/free-turbine APU example; do not assume it matches a three-shaft model |
| OpenMDAO, [pyCycle](https://github.com/OpenMDAO/pyCycle) | Open-source thermodynamic cycle modeling reference | Useful for cycle-analysis structure and thermo-package sensitivity; inspect license and theory before reusing code |
| OpenAI, [skills](https://github.com/openai/skills) | Codex skill packaging patterns | Use for skill structure and installation patterns, not thermodynamic equations |
| MathWorks, [MATLAB Agentic Toolkit](https://github.com/matlab/matlab-agentic-toolkit) | MATLAB MCP tools and MATLAB skill workflow | Use for static analysis, execution, tests, and MATLAB workflow guardrails |
| MathWorks, [Simulink Agentic Toolkit](https://www.mathworks.com/products/simulink-agentic-toolkit.html) | Structured model access and Simulink workflow | Use for `model_overview`, `model_read`, `model_edit`, simulation, testing, and traceability workflows |

## Source Use Rules For Gas Turbine Modeling

Use NASA Glenn and similar educational sources for first-principles checks:

- Compressor temperature ratio and work direction.
- Turbine pressure ratio and work extraction sign.
- Compressor-turbine shaft matching logic.
- Design-point versus off-design distinction.

Use MathWorks documentation for implementation conventions:

- Corrected flow and corrected speed map conventions.
- Dynamic compressor and turbine map table requirements.
- Simulink/Simscape block capabilities and limitations.

Use open-source cycle tools such as pyCycle for architecture comparison:

- Compare how components, thermodynamic packages, solvers, and balance variables are organized.
- Do not copy equations or code without checking license, theory, tests, and applicability.
- Record when differences come from thermodynamic property packages. pyCycle explicitly notes that switching thermodynamic packages changes answers.

Use user-provided models first when they exist:

- If a user MATLAB/Simulink model has a validated formula, treat it as project evidence.
- Use external sources to explain, audit, or replace the formula only after recording the difference.
- Never silently replace a user-derived cooled/bleed multi-spool formula with a simpler ideal-cycle relation.

## Formula Selection Gate

Before coding a new equation into MATLAB or Simulink, present:

- Candidate formula.
- Source and applicability.
- Units and variable definitions.
- Known assumptions.
- Expected design-point check.

Proceed only after the user confirms or after clearly marking the implementation as exploratory.
