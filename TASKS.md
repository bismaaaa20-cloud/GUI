# XevoraHub — Task Board

Tasks must have a clear owner, status, and acceptance criteria. Do not start a task marked **Blocked** or **Needs approval**.

## Status key
- **Not started**
- **In progress**
- **Blocked**
- **Needs approval**
- **Done**

## Stage 1 — Repository audit
- **Status:** Not started
- **Executor:** ChatGPT
- **Reviewer:** Claude
- **Scope:** Read-only inspection. Do not modify runtime files.
- **Goal:** Understand the existing repository before planning code changes.

### Checklist
- [ ] Inventory all root files and folders.
- [ ] Read the README and identify the purpose of each existing source/asset file.
- [ ] Identify the main entry point, loading flow, and script relationships where evidence is available.
- [ ] Note external URLs, dependencies, and configuration assumptions without exposing secrets.
- [ ] Identify risks, unclear behavior, and missing documentation.
- [ ] Update `HANDOFF.md` with findings and propose the next small task.

### Acceptance criteria
- A concise repository map exists.
- Findings distinguish confirmed facts from assumptions.
- No runtime file has been changed.
- Claude can review the audit and recommend the next stage.

## Future tasks
Add new tasks only after the user approves their scope. Keep each task small enough to review independently.
