#!/usr/bin/env python3
"""Release checks for the public energy AI modeling skills package."""

from __future__ import annotations

import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]

REQUIRED_FILES = [
    "README.md",
    "AGENTS.md",
    "LICENSE",
    "CONTRIBUTING.md",
    "CODE_OF_CONDUCT.md",
    "SECURITY.md",
    "docs/privacy-review.md",
    "docs/release-checklist.md",
    "docs/external-review-prompts.md",
]

SKILL_DIRS = [
    ROOT / "skills" / "thermal-machinery-dynamic-modeling",
    ROOT / "skills" / "gas-turbine-ai-modeling",
]

BLOCKED_EXTENSIONS = {
    ".slx",
    ".slxc",
    ".mdl",
    ".docx",
    ".pptx",
    ".pdf",
    ".mat",
    ".mlx",
    ".xlsx",
    ".xls",
    ".xlsm",
    ".zip",
    ".7z",
    ".rar",
    ".fig",
    ".png",
    ".jpg",
    ".jpeg",
    ".tif",
    ".tiff",
    ".h5",
    ".hdf5",
    ".bak",
    ".tmp",
}

BLOCKED_FILENAME_FRAGMENTS = {
    ".slx.",
    ".slxc.",
}

SENSITIVE_PATTERNS = [
    r"[A-Za-z]:\\",
    r"\\Users\\",
    r"\bhome[/\\]",
]

TEXT_EXTENSIONS = {
    ".md",
    ".yaml",
    ".yml",
    ".json",
    ".csv",
    ".txt",
    ".py",
    ".m",
    ".gitignore",
}

ALLOWED_EXAMPLE_EXTENSIONS = {
    ".md",
    ".csv",
    ".m",
}


def text_files() -> list[Path]:
    files: list[Path] = []
    for path in ROOT.rglob("*"):
        if not path.is_file():
            continue
        if path.name == ".gitignore" or path.suffix.lower() in TEXT_EXTENSIONS:
            files.append(path)
    return files


def rel(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def check_required_files(errors: list[str]) -> None:
    for item in REQUIRED_FILES:
        if not (ROOT / item).is_file():
            errors.append(f"missing required file: {item}")


def check_skill_structure(errors: list[str]) -> None:
    for skill_dir in SKILL_DIRS:
        skill_file = skill_dir / "SKILL.md"
        if not skill_file.is_file():
            errors.append(f"missing SKILL.md: {rel(skill_dir)}")
            continue
        text = skill_file.read_text(encoding="utf-8", errors="replace")
        if not text.startswith("---"):
            errors.append(f"missing YAML frontmatter: {rel(skill_file)}")
        if "name:" not in text.split("---", 2)[1]:
            errors.append(f"missing name in frontmatter: {rel(skill_file)}")
        if "description:" not in text.split("---", 2)[1]:
            errors.append(f"missing description in frontmatter: {rel(skill_file)}")


def check_blocked_files(errors: list[str]) -> None:
    for path in ROOT.rglob("*"):
        if not path.is_file():
            continue
        name = path.name.lower()
        if path.suffix.lower() in BLOCKED_EXTENSIONS:
            errors.append(f"blocked binary/private file type: {rel(path)}")
        elif any(fragment in name for fragment in BLOCKED_FILENAME_FRAGMENTS):
            errors.append(f"blocked generated model backup file: {rel(path)}")


def check_sensitive_text(errors: list[str]) -> None:
    patterns = list(SENSITIVE_PATTERNS)
    local_denylist = ROOT / ".release-denylist.local"
    if local_denylist.is_file():
        for line in local_denylist.read_text(encoding="utf-8", errors="replace").splitlines():
            item = line.strip()
            if item and not item.startswith("#"):
                patterns.append(re.escape(item))
    compiled = [re.compile(pattern, re.IGNORECASE) for pattern in patterns]
    for path in text_files():
        if path == Path(__file__).resolve():
            continue
        text = path.read_text(encoding="utf-8", errors="replace")
        for line_no, line in enumerate(text.splitlines(), start=1):
            for pattern in compiled:
                if pattern.search(line):
                    errors.append(f"sensitive text hit: {rel(path)}:{line_no}: {line.strip()[:160]}")


def check_examples(errors: list[str]) -> None:
    examples = ROOT / "examples"
    if not examples.is_dir():
        errors.append("missing examples directory")
        return
    for path in examples.rglob("*"):
        if path.is_file() and path.suffix.lower() not in ALLOWED_EXAMPLE_EXTENSIONS:
            errors.append(f"example contains unsupported file type: {rel(path)}")


def main() -> int:
    errors: list[str] = []
    check_required_files(errors)
    check_skill_structure(errors)
    check_blocked_files(errors)
    check_sensitive_text(errors)
    check_examples(errors)

    if errors:
        print("Repository release checks failed.")
        for err in errors:
            print(f"- {err}")
        return 1

    print("Repository release checks passed.")
    print("These checks cover file structure, privacy, and packaging only; they do not validate engineering models.")
    print(f"Checked root: {ROOT}")
    print(f"Checked skills: {len(SKILL_DIRS)}")
    print(f"Checked text files: {len(text_files())}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
