# Contributing

Thanks for improving these energy-system modeling skills.

## Scope

Contributions should improve reusable AI-assisted modeling workflows for thermal machinery, gas turbines, or closely related energy-conversion systems.

Good contributions include:

- clearer staged modeling procedures;
- better node-ledger, component-contract, or validation templates;
- synthetic examples;
- privacy-safe validation tasks;
- documentation fixes;
- scripts that audit public or user-provided files without embedding private data.

Do not contribute:

- private project files;
- unpublished thesis or manuscript material;
- manufacturer data that is not public;
- full Simulink models or MATLAB data files unless they are intentionally public examples;
- claims that a model is validated without mass, energy, pressure, initialization, and source checks.

## Skill Design Rules

- Keep `SKILL.md` concise and put detailed procedures in `references/`.
- Make trigger descriptions clear enough that an agent knows when to use the skill.
- Prefer reusable workflow rules over one-off project details.
- Use synthetic examples when demonstrating sensitive workflows.
- Keep units, assumptions, and validation gates explicit.

## Privacy Rules

Before opening a pull request, check that no local paths, personal identifiers, private model names, binary research files, or non-public data are included.

Run:

```bash
python scripts/validate_release.py
```

Review any warning manually.

## Pull Request Checklist

- [ ] Skill metadata is valid.
- [ ] New or changed references are linked from `SKILL.md` when needed.
- [ ] Examples are synthetic, public, or explicitly licensed.
- [ ] No private MATLAB/Simulink model files are included.
- [ ] Validation and privacy checks pass.
- [ ] Limitations and assumptions are stated.
