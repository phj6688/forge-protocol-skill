---
name: forge-protocol
description: >
  Use when the user mentions "forge", "forge protocol", "/forge-protocol",
  wants to set up a FORGE project, create a TASKSPEC, run an audit, generate
  session prompts, execute session gates, do scar loading, or manage
  multi-session agent-delegated development. Also trigger when user asks
  about spec-driven agent workflows, verification gates, regression
  enforcement, scar-based failure injection, or session dependency DAGs.
  NEVER trigger for generic project setup or test writing outside of FORGE context.
version: 3.1.0
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash, Agent]
---

# FORGE v3.1 -- Autonomous Agent Delegation Protocol

*Shape it once. Strike until it holds.*

Multi-session agent delegation with spec-driven execution, autonomous gate verification, and invisible workflow artifacts.

Solves: **context decay** (spec loaded every session), **compounding rot** (gates block progression), **regression blindness** (test suite catches breakage), **spec-drift** (discovery grounds the spec in reality before execution begins).

FORGE guarantees derivation integrity, not spec correctness. Wrong spec = wrong build, done correctly. Discovery exists to catch the "wrong spec" case before agents waste sessions on it.

---

## Principles

1. **Spec-driven.** Everything derives from TASKSPEC.md. Agents derive, never guess.
2. **Ground truth first.** Before agents execute, the spec is verified against the actual codebase. Requirements from external sources (tickets, PRs, conversations) are claims, not facts. Discovery checks the claims.
3. **Autonomous execution.** Agents build, run gates, produce reports. Humans review results only.
4. **Invisible workflow.** Git history looks human-built. FORGE artifacts never reach the repo.
5. **Feature-oriented git.** Branches and tags describe what was built, not which session built it.
6. **Test suite as regression.** The test suite verifies prior work. No individual gate replay.

---

## Architecture

```
SPEC (.forge/TASKSPEC.md)       <- ground truth, append-only
  |
DISCOVERY (.forge/DISCOVERY.md) <- verify spec against actual codebase
  |
AUDIT (.forge/AUDIT.md)         <- risk assessment + scar extraction
  |
SESSION PROMPTS                 <- spec + discovery + scars -> scoped work + gates
  |
AUTONOMOUS EXECUTION            <- agent builds, runs gates, reports
  |
HUMAN REVIEW                    <- reads verdict -> proceed / review / blocked
```

| Actor | Does | Does NOT |
|-------|------|----------|
| Orchestrator | Plans DAG, runs discovery, generates prompts, delegates to executor agents, manages state | Write project code |
| Executor(s) | Build, test, run all gates, commit, produce session reports | Decide to proceed to next session |
| Human | Reads session reports, go/no-go decisions, spec corrections when needed | Run gates, type commands, manage branches |

---

## Git Conventions

**Branches** -- derived from session titles in Build Order:
`feat/data-layer`, `feat/signal-engine`, `fix/auth-timeout`.
Parallel sessions on parallel branches. Merge to `dev` after approval. Never direct to `main`.

**Tags** -- semantic versions applied after merge to `dev`:
`v0.1.0`, `v0.2.0`. Session-to-version mapping defined in Build Order.

**Commits** -- conventional format referencing the feature:
`feat: add dual-lane signal engine with redis caching`.
No session numbers. No FORGE terms. No AI attribution. No session references in messages.

**Artifacts** -- everything FORGE-related lives in `.forge/` (gitignored):
```
.forge/
  TASKSPEC.md                   # canonical spec
  DISCOVERY.md                  # spec-vs-reality verification
  AUDIT.md                      # audit or risk report
  AUDIT-SCARS.md                # archived scars (large projects)
  state.json                    # DAG progress
  sessions/
    01-data-layer/
      prompt.md
      output.md
    02-signal-engine/
      prompt.md
      output.md
```

Only `CLAUDE.md` stays in project root (standard Claude Code file, not FORGE-specific).

---

## Components

### 1. Canonical Spec

`.forge/TASKSPEC.md` -- the project constitution. Contains: mission, stack, directory structure, data model, features with acceptance criteria, failure handling, env vars, and Build Order.

**Build Order** defines each session:
- **Title** (drives branch name: "Data Layer" -> `feat/data-layer`)
- **Depends on** (DAG edges for parallel dispatch)
- **Deliverables** (checklist)
- **Verification gates** (runnable commands the agent executes)
- **Quality gates** (BLOCK/WARN level)
- **Branch** (e.g. `feat/data-layer`)
- **Tag** (e.g. `v0.1.0`)

Append-only during execution. Corrections via addendum + version increment (v1.0 -> v1.1). Original text stays frozen.

Session count heuristic: `N ~ ceil(total_features / (context_budget * 0.6))`

### 2. Codebase Discovery

Runs after the spec is written, before the audit. The orchestrator reads the actual codebase and checks every assumption the spec makes. Discovery catches spec-drift -- the gap between what the requirements doc says and what the code actually does.

**Discovery checks:**

| Check | What to verify | How |
|-------|---------------|-----|
| **File collisions** | Does a file the spec says "create" already exist? | `ls` / `find` every target path |
| **Package manager** | Does the spec assume the right one? | Check for `package-lock.json` (npm), `pnpm-lock.yaml` (pnpm), `yarn.lock` (yarn), `bun.lockb` (bun) |
| **Naming conventions** | Do new models/files/routes match existing patterns? | Read the last 3-5 similar entities in the codebase |
| **CI environment** | Are env vars set to what the spec assumes? | Read the CI workflow file |
| **Migration format** | Does the migration naming match the project convention? | `ls` the migrations directory |
| **Schema conventions** | Do new DB models match existing ORM patterns? | Read the last model added to the schema |
| **Dependency state** | Are assumed packages already installed? | `grep` the lockfile or `package.json` |
| **Script naming** | Do new scripts match existing `package.json` conventions? | Read the scripts block |

**Output:** `.forge/DISCOVERY.md` -- a list of every spec assumption that was verified, with corrections for any that don't match reality. If corrections are found, the orchestrator amends the TASKSPEC (version increment) before proceeding to audit.

**When to skip:** Pure greenfield projects with no existing codebase. If the `.forge/TASKSPEC.md` Provenance field says `greenfield` and no code exists yet, skip discovery.

**Why this exists:** Requirements from external systems (Linear, Jira, PRDs, conversations) are written by humans who may not know the current state of the codebase. "Use pnpm" in a ticket doesn't make pnpm the package manager. "Create AI_PLATFORM_GUIDE.md" doesn't mean the file doesn't already exist. Discovery is the step that turns claims into verified facts.

### 3. Audit / Risk Assessment

**Brownfield (existing code):** Agent reads codebase, produces per-module verdicts:
KEEP / PATCH / REWRITE / DELETE / UNCERTAIN.
Extracts structured scars from discovered failures.

**Greenfield (new project):** Agent reads spec, projects risk per module:
SIMPLE / MODERATE / COMPLEX / RISKY.
Extracts scar seeds from projected failure modes.

**Hybrid (new features on existing infrastructure):** Treat as brownfield. Read the modules the spec touches, produce verdicts for those, project risk for new modules. Discovery must have already run.

### 4. Scar Loading

Concrete failure injection into session prompts. Each scar:

| Field | Format |
|-------|--------|
| ID | S{session}-{N}, A{N} (audit), D{N} (discovery), or R{N} (risk) |
| Category | DATA-LOSS / SILENT-FAILURE / PERFORMANCE / CORRECTNESS / SECURITY / INTEGRATION / BUILD / SPEC-DRIFT |
| Description | Concrete past or projected failure -- never abstract advice |
| Severity | CRITICAL / HIGH / MEDIUM / LOW |

**SPEC-DRIFT** -- the spec assumed something about the codebase that isn't true. Examples: wrong package manager, file already exists at target path, naming convention mismatch, CI env var set to a dummy value, migration format doesn't match project convention. Discovery produces these; they're injected into session prompts so executors don't repeat the same mistakes.

**Loading priority:** CRITICAL always included. HIGH if relevant to this session's modules. MEDIUM from last two sessions only. LOW archived.

**Global scars:** Cross-project scars in `references/global-scars.md` are loaded into EVERY session prompt alongside project-specific scars. These encode failure patterns that recur across projects (binary file misclassification, env-var silent failures, etc.). Add new global scars when a failure pattern is project-agnostic.

**Pruning (>6 sessions):** Retain last two sessions + all CRITICAL. Archive rest to `.forge/AUDIT-SCARS.md`.

### 5. Session Prompts

Self-contained execution cartridges carrying:
- Spec reference (exact version, e.g. `v1.2`)
- Deliverables from Build Order
- Codebase context (from Discovery -- conventions, existing files, verified facts)
- Scar load (priority-ordered, including SPEC-DRIFT scars from discovery)
- Discoveries forwarded from completed sessions
- Verification gates + quality gates
- Branch name + version tag (from Build Order)
- Autonomous execution instructions (agent runs everything, produces report)

### 6. Session DAG + Parallel Dispatch

Sessions declare `depends_on` in Build Order. Independent sessions run concurrently.

```
S1 -> S2a (parallel) -> S3 (merge) -> S4
       S2b (parallel) /
```

**Parallel dispatch:** Orchestrator spawns one executor Agent per independent session, each in its own worktree (branch isolation). All execute concurrently.

**Merge sessions:** After parallel tracks complete, a dedicated merge session integrates branches into `dev`. The merge session runs the full test suite as regression. Conflicts resolved during merge.

### 7. Autonomous Execution

Each executor agent, without human intervention:
1. Creates feature branch from `dev`
2. Implements all deliverables
3. Writes tests for new functionality
4. Runs verification gates (functional: does it work?)
5. Runs quality gates (non-functional: BLOCK must pass, WARN gets logged)
6. Runs the full test suite (regression: does prior work still hold?)
7. Commits with conventional messages (feature-oriented, no FORGE terms)
8. Produces session output report ending with a human action verdict

**Verification gates** -- discrete runnable commands testing this session's deliverables. Defined in the spec at planning time, not invented during execution.

**Quality gates** -- two tiers:
- BLOCK: must pass (security lint, no hardcoded secrets, type checking)
- WARN: logged for human awareness (bundle size, coverage drop, new dependencies)

**Regression** -- run the project's full test suite. Passing suite = all prior sessions verified. First session also establishes test infrastructure and runner.

### 8. Session Report + Human Action

Every session produces a structured output report: status, deliverables completed, gate results (table), confidence per deliverable (HIGH/MEDIUM/LOW), discoveries, deviations from spec, new scars from failures encountered.

The report ends with a **Human Action** block:

```
## Human Action

VERDICT: PROCEED / REVIEW / BLOCKED

[PROCEED]
All gates passed. Confidence HIGH across deliverables.
-> Merge feat/[name] to dev, tag v[X.Y.Z].
-> Next: [session title]. Orchestrator can generate prompt.

[REVIEW]
Gates passed but attention needed:
- [ ] Review: [specific area or concern]
- [ ] Decide: [question requiring human judgment]
Estimated review: ~N minutes.

[BLOCKED]
Cannot proceed until resolved:
- [ ] [issue with root cause analysis]
- [ ] [what must happen before retry]
```

The human reads the verdict. PROCEED = move on. REVIEW = check flagged items then move on. BLOCKED = fix something.

### 9. Recovery + Spec Corrections

**Gate failure:** Agent attempts fix in current session, re-runs all gates. If fix-forward fails twice -> report BLOCKED with root cause.

**Test regression:** If this session caused it -> agent fixes forward. If pre-existing cause -> report BLOCKED with diagnosis.

**Spec is wrong:** Human adds addendum to TASKSPEC.md: original assumption, what reality revealed, corrected assumption, affected sessions. Version increments. Orchestrator regenerates affected prompts.

---

## Execution Flow

1. **Init** -- `forge init project-name` scaffolds `.forge/` structure with TASKSPEC template
2. **Spec** -- human writes `.forge/TASKSPEC.md` with Build Order (titles, branches, tags, DAG)
3. **Discovery** -- orchestrator reads every file the spec touches or creates, verifies conventions, env vars, naming, existing files. Produces `.forge/DISCOVERY.md`. If corrections found, amends TASKSPEC (version increment) before proceeding. Skip for pure greenfield.
4. **Audit** -- orchestrator delegates audit (brownfield/hybrid) or risk speculation (greenfield) to an agent. Scars extracted. Discovery scars (SPEC-DRIFT) loaded alongside audit scars.
5. **Prompt** -- orchestrator generates session prompt from spec + discovery + audit + scars + prior discoveries
6. **Execute** -- orchestrator delegates prompt to executor agent. Agent works autonomously: build -> gates -> report. Parallel sessions dispatched concurrently via separate agents in worktree isolation.
7. **Report** -- agent produces session output ending with HUMAN ACTION verdict
8. **Review** -- human reads verdict. PROCEED -> merge branch to dev, tag, next prompt. REVIEW -> check flagged items. BLOCKED -> resolve issue.
9. **Repeat** until Build Order complete.

---

## Failure Modes

| Failure | Mitigation |
|---------|------------|
| Wrong spec | Discovery verifies spec assumptions against codebase before audit. Human reviews Discovery corrections. |
| Spec-drift from requirements | Discovery checks every "create file" target, package manager assumption, naming convention, CI env var. SPEC-DRIFT scars injected into sessions. |
| Audit false KEEP | UNCERTAIN verdict required for partially-read files |
| Scar bloat | Priority loading + archival pruning |
| Prompt drifts from spec | Prompts reference exact spec version |
| Spec-rot | Addendum protocol with version increment |
| Regression | Test suite catches it; recovery protocol handles it |
| Context too large | Budget estimate in prompt; split oversized sessions |
| Parallel merge conflict | Dedicated merge session with full test regression |

---

## Quick Reference

| Action | How |
|--------|-----|
| Start project | `forge init my-project` |
| Write spec | Edit `.forge/TASKSPEC.md` |
| Verify spec against codebase | `forge discover` |
| Audit existing code | `forge audit` |
| Assess greenfield risk | `forge risk` |
| Generate session prompt | `forge prompt 1` |
| Run gates locally | `forge gate 1` |
| Merge and tag session | `forge merge 1` |
| Check project status | `forge status` |
| Add a scar | `forge scar add "description"` |
| Validate spec structure | `forge validate` |

For all templates, see `references/templates.md`.
