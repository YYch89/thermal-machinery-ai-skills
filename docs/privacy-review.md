# Privacy Review

This repository is intended to contain public methodology, templates, validation tasks, and synthetic examples.

## Excluded From Public Export

- Private MATLAB or Simulink source models.
- Local absolute paths.
- Personal names or usernames.
- Thesis drafts, unpublished manuscript text, and private reports.
- Raw manufacturer data or non-public component maps.
- Real project calibration data unless explicitly approved for release.

## Included

- General modeling workflows.
- Public skill instructions.
- Generic component contracts.
- Synthetic examples and reduced validation artifacts.
- Public MATLAB `.m` example code that uses synthetic inputs and does not embed
  private model data.
- MATLAB audit scripts that inspect a user-provided model without embedding
  private model data.

## Maintainer Checklist Before GitHub Push

Run a text scan for Windows absolute-drive paths, home-directory fragments, personal names, local project folder names, private model filenames, and binary research artifacts such as Simulink models, Word documents, PDFs, and MATLAB data files.

For project-specific private terms, create a local `.release-denylist.local` file with one term per line. This file is ignored by git and should not be published.

Review any hit manually before publishing.
