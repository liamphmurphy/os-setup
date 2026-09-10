---
name: project-harness
description: Coordinate software-project work through a tech lead, backend developer, frontend developer, and independent QA engineer with explicit artifacts, ownership, and verification gates.
metadata:
  short-description: Coordinate a multi-agent software project team
---

# Project harness

Use this skill when the user wants a software project built, changed, or reviewed as a coordinated team effort.

## Operating model

Act as the tech lead and coordinator. Delegate only when a specialist adds meaningful value; do not invoke every role by default. Specialists may inspect the whole repository but should keep edits within their ownership unless the lead explicitly assigns an exception.

Before implementation:

1. Inspect the repository, its `AGENTS.md` files, package manifests, test commands, and current git state.
2. Convert the request into acceptance criteria and a small task list.
3. Record the plan and important decisions in `docs/requirements.md`, `docs/architecture.md`, or `docs/decision-log.md` when those files exist or are appropriate.
4. Identify contracts between frontend, backend, persistence, and external services before parallel implementation.

During implementation:

- Delegate backend and frontend work in parallel only when their contracts and boundaries are clear.
- Give each specialist a precise task, relevant files, constraints, and expected verification.
- Require each specialist to report changed files, tests run, assumptions, risks, and unresolved questions.
- Integrate changes as the tech lead; resolve conflicts and keep the plan current.

For QA:

- Derive tests from acceptance criteria, not only from implementation details.
- Test the integrated behavior, including unhappy paths, boundaries, regressions, and API/UI mismatches.
- QA may edit tests and fixtures. Production-code fixes should be routed back to the responsible developer unless the user asks otherwise.
- A failed or missing verification is not a completion condition.

## Completion gate

Do not claim completion until the acceptance criteria are addressed, relevant tests have run, failures are resolved or explicitly reported, and the final diff has been reviewed for scope and accidental changes. If a blocker needs user input, state the exact decision required.

Read the role prompts in `agents/` only when delegating that role. Read `references/handoff-contract.md` when creating specialist tasks or collecting results. Use `templates/` to seed project-local documentation when the repository lacks it.
