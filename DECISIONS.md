# XevoraHub — Decision Log

Record decisions that affect project direction or collaboration. Newest decisions go first. Do not silently reverse a decision; add a new entry explaining the change.

## Confirmed decisions

### 2026-10-31 — Shared repository workflow
- **Decision:** GitHub repository `bismaaaa20-cloud/GUI` is the shared source of truth for this collaboration.
- **Reason:** Both AI workflows need a durable place to read current project state and hand off work.

### 2026-10-31 — AI roles
- **Decision:** Claude plans/specifies and reviews; ChatGPT implements, debugs, and performs available checks; the user makes final decisions.
- **Reason:** Clear ownership reduces conflicting edits and makes review easier.

### 2026-10-31 — One executor per task
- **Decision:** Only one AI implements a task at a time. The other AI reviews the diff and reports issues with file/path references.
- **Reason:** Avoid parallel edits and contradictory changes.

### 2026-10-31 — Protect existing runtime files
- **Decision:** Existing Lua scripts and runtime assets are out of scope unless the user explicitly approves a task that needs them.
- **Reason:** Documentation setup must not affect the loader, key system, game mappings, UI, or other scripts.

### 2026-10-31 — Review before merging
- **Decision:** Prefer focused branches and pull requests. Do not merge a pull request or push unrelated changes to `main` without the user's approval.
- **Reason:** The user should inspect and approve changes before they become part of the main branch.

### 2026-10-31 — Honest verification
- **Decision:** Report only checks that were actually run. Clearly label untested behavior and unavailable test environments.
- **Reason:** Avoid false confidence about runtime compatibility.

### 2026-10-31 — Keep credentials out of Git
- **Decision:** Never commit API keys, tokens, passwords, private keys, or other secrets.
- **Reason:** Protect accounts and project infrastructure.

## Pending decisions
- Confirm the intended long-term product scope and whether this repository will remain the home for all XevoraHub components.
- Define automated checks once the repository's build/test setup is understood.
