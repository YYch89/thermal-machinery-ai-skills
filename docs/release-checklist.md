# Release Checklist

Use this checklist before publishing to GitHub or tagging a release.

## Content

- [ ] README explains what the project is and is not.
- [ ] Each skill has valid `SKILL.md` frontmatter.
- [ ] Detailed references are linked from each `SKILL.md`.
- [ ] Examples are synthetic, public, or explicitly approved.
- [ ] License is present.
- [ ] Contribution, conduct, security, and privacy notes are present.

## Privacy

- [ ] No personal names or local usernames.
- [ ] No local absolute paths.
- [ ] No private model filenames.
- [ ] No thesis drafts, unpublished reports, or manuscript text.
- [ ] No raw manufacturer maps or private calibration data.
- [ ] No binary research assets are accidentally included.

## Engineering Claims

- [ ] The README says the skills are workflow aids, not certified engineering tools.
- [ ] Examples are labeled synthetic/reduced where appropriate.
- [ ] Validation limits are stated.
- [ ] No performance or efficiency result is presented as a real machine claim unless source-backed.

## Automated Checks

Run:

```bash
python scripts/validate_release.py
```

Expected result:

```text
Repository release checks passed.
These checks cover file structure, privacy, and packaging only;
they do not validate engineering models.
```

## External Review

- [ ] Run privacy review prompt.
- [ ] Run skill-usability review prompt.
- [ ] Run engineering-safety review prompt.
- [ ] Address or explicitly defer findings.
