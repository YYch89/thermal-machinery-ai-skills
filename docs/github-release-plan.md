# GitHub Release Plan

## Recommended First Release

Release as `v0.1.0`.

Suggested repository name:

```text
thermal-machinery-ai-skills
```

Suggested repository description:

```text
AI-agent workflows for staged dynamic modeling of gas turbines and coupled thermal-machinery systems.
```

Suggested topics:

```text
codex-skills, ai-agents, ai-engineering, thermal-machinery, gas-turbine, thermodynamics, simulink, matlab, dynamic-modeling, energy-systems
```

Suggested short positioning:

```text
Not just prompts. Not just code generation. This project turns thermal-machinery modeling experience into reusable AI-agent workflows.
```

Suggested Chinese positioning:

```text
面向复杂热力机械动态建模的开源 AI Agent Skill：不是简单提示词，也不是单纯代码生成，而是把能动领域建模经验沉淀为可复用、可验证的科研工作流。第一版已在可运行的燃气轮机 MATLAB/Simulink 合成示例上完成 smoke-check 验证。
```

## Before Creating The Repository

1. Run `python scripts/validate_release.py`.
2. Read `docs/privacy-review.md`.
3. Run external GPT review using `docs/external-review-prompts.md`.
4. Confirm the repository is created from this sanitized public folder only.
5. Check the rendered README on GitHub after the first push.

## Initial GitHub Issue Ideas

- Add more public synthetic examples for Rankine, refrigeration, and heat-pump systems.
- Add more gas-turbine examples for alternate shaft arrangements and control objectives.
- Add automated tests for table schemas.
- Add a public example of design-to-dynamic initial-condition mapping.

## Suggested Release Notes

```text
Initial public release.

Includes:
- thermal-machinery-dynamic-modeling general workflow skill;
- gas-turbine-ai-modeling domain skill;
- synthetic dual-shaft gas-turbine dynamic example;
- synthetic heat-pump stream-ledger example;
- privacy and release validation checklist.

Runtime notes:
- repository release checks passed;
- gas-turbine MATLAB/Simulink smoke checks verified with MATLAB/Simulink R2023a;
- generated Simulink binaries and cache files are intentionally excluded.
```
