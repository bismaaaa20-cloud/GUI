# XevoraHub — Project Context

## Purpose
This repository is the shared source of truth for XevoraHub. The current repository contains Roblox/Lua-related files, including `Loader.lua`, `Games.lua`, `Keys.lua`, `Main UI`, and a logo asset.

## Collaboration rules
- The user is the project owner and final decision-maker.
- Claude acts as product architect, prompt/spec writer, technical planner, and reviewer.
- ChatGPT acts as implementation/debugging assistant and can inspect repository files, propose changes, and run available checks.
- GitHub is the source of truth; chat history is not a substitute for repository documentation.
- Only one AI implements a given task at a time. The other reviews the resulting diff.
- Keep work small and reviewable. Prefer a branch and pull request over direct changes to `main`.

## Safety and scope boundaries
- Existing runtime scripts are protected by default. Do not edit, rename, move, delete, or reformat `Loader.lua`, `Games.lua`, `Keys.lua`, `Main UI`, or other runtime assets unless the user explicitly approves a task that requires it.
- These four collaboration documents are documentation only. They must not be imported, required, or executed by any Lua script.
- Documentation work must not change loader URLs, key logic, Luarmor integration, game mappings, UI behavior, or runtime dependencies.
- Never add API keys, access tokens, passwords, private keys, or personal credentials to this repository.
- Never claim code was tested unless the relevant test/check was actually run. State unavailable checks clearly.

## Task workflow
1. Read this file and the other collaboration documents before starting.
2. Confirm task, scope, protected files, and acceptance criteria.
3. Inspect relevant files before editing.
4. Make only the smallest necessary change on a dedicated branch.
5. Run relevant checks when possible and report exact results.
6. Summarize changed files and risks; provide the commit/PR reference.
7. Update `HANDOFF.md` so the next AI can continue without guessing.

## Repository notes
The current root inventory is recorded in `HANDOFF.md`. Update it after future audits; do not assume this initial inventory remains complete.
