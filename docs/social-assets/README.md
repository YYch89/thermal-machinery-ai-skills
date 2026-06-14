# Social Launch Assets

This folder contains editable source text for the first public social announcement of Thermal Machinery AI Skills.

Rendered PNG files are intentionally not stored in the repository because the release validator blocks binary assets. Render them locally when preparing a post.

## Files

- `xhs-launch-cards.md`: source Markdown for Xiaohongshu image cards.
- `douyin-cover.md`: source Markdown for a Douyin vertical cover.

The assets intentionally avoid internal research directions and only describe the public gas-turbine and general thermal-machinery AI modeling repository.

## Render

Use the local Xiaohongshu card renderer:

```powershell
$env:PYTHONIOENCODING='utf-8'
python "$env:USERPROFILE\.codex\skills\xhs-note-creator\scripts\render_xhs.py" "docs\social-assets\xhs-launch-cards.md" --output-dir "..\..\social-launch-assets\thermal-machinery-ai-skills\xhs-launch" --theme professional --mode separator --width 1080 --height 1440 --dpr 2
python "$env:USERPROFILE\.codex\skills\xhs-note-creator\scripts\render_xhs.py" "docs\social-assets\douyin-cover.md" --output-dir "..\..\social-launch-assets\thermal-machinery-ai-skills\douyin-launch" --theme terminal --mode auto-fit --width 1080 --height 1920 --dpr 2
```
