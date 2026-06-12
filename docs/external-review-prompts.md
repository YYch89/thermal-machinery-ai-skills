# External GPT Review Prompts

Use these prompts with a separate GPT or reviewer before publishing. Do not include private project context. Provide only the public repository files.

## Review 1: Privacy And Publication Safety

```text
You are reviewing a public GitHub candidate repository for privacy and publication safety.

Repository purpose:
Open-source Codex skills for AI-assisted modeling of thermal machinery and gas turbines.

Please inspect the repository text and file list for:
1. local absolute paths or home-directory fragments;
2. personal names, usernames, or private identifiers;
3. private model filenames or project-specific raw source names;
4. thesis, manuscript, report, or unpublished research content;
5. binary research assets that should not be public;
6. examples that appear to be real engineering data but are not labeled as synthetic;
7. license or disclaimer gaps.

Return:
- blocking issues;
- non-blocking concerns;
- exact file paths and lines when available;
- recommended edits.

Do not judge the technical quality unless it affects publication safety.
```

## Review 2: Skill Usability

```text
You are reviewing whether these Codex skills are usable by an AI agent that has no prior conversation context.

Please check:
1. whether each `SKILL.md` has a clear trigger description;
2. whether the workflow is actionable without private files;
3. whether references are discoverable and not overloaded;
4. whether output artifacts are concrete enough to guide an agent;
5. whether examples help without leaking private data;
6. whether the difference between the general thermal-machinery skill and gas-turbine skill is clear.

Return:
- what works well;
- unclear or missing instructions;
- places where an agent might still jump directly to code or Simulink;
- recommended edits.
```

## Review 3: Engineering Safety And Claims

```text
You are reviewing an open-source AI engineering workflow repository for engineering-safety risks.

Please check:
1. whether the repository overclaims validation or engineering authority;
2. whether examples could be mistaken for certified design data;
3. whether the skills require mass, species, energy, pressure, and dynamic-initialization checks before claiming completion;
4. whether safety-critical use is properly disclaimed;
5. whether reduced models are labeled honestly;
6. whether missing data, assumptions, empirical fits, and source provenance are handled responsibly.

Return:
- blocking safety concerns;
- ambiguous wording that should be softened;
- validation gates that should be stronger;
- suggested README or reference edits.
```

## Review 4: Blind Skill Test

```text
You are testing these skills as if you were an AI agent using them for the first time.

Task:
Use the thermal-machinery-dynamic-modeling skill to plan a first-pass dynamic model for a recuperated gas turbine with a compressor, combustor, turbine, recuperator, shaft inertia, and load. The user only provides target net power and turbine inlet temperature.

Do not write code. Produce the workflow artifacts the skill asks for.

After answering, self-review:
1. Did you ask or list missing scope and data?
2. Did you build a node-by-node stream ledger?
3. Did you define component contracts?
4. Did you avoid jumping directly to dynamic simulation?
5. Did you state validation gates and unresolved assumptions?

Return both the model-planning answer and the self-review.
```

## How To Use Results

Treat external reviews as findings, not commands. For each finding, decide:

- fix now;
- defer with reason;
- reject with reason.

Record the decision in release notes or an issue before publishing.
