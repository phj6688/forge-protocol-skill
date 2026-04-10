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
version: 3.0.0
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash, Agent]
---

# FORGE v3 -- Autonomous Agent Delegation Protocol

*Shape it once. Strike until it holds.*

Multi-session agent delegation with spec-driven execution, autonomous gate verification, and invisible workflow artifacts.

Solves: **context decay** (spec loaded every session), **compounding rot** (gates block progression), **regression blindness** (test suite catches breakage).

FORGE guarantees derivation integrity, not spec correctness. Wrong spec = wrong build, done correctly.

---

## Principles

1. **Spec-driven.** Everything derives from TASKSPEC.md. Agents derive, never guess.
2. **Autonomous execution.** Agents build, run gates, produce reports. Humans review results only.
3. **Invisible workflow.** Git history looks human-built. FORGE artifacts never reach the repo.
4. **Feature-oriented git.** Branches and tags describe what was built, not which session built it.
5. **Test suite as regression.** The test suite verifies prior work. No individual gate replay.

---

## Architecture

```
SPEC (.forge/TASKSPEC.md)       <- ground truth, append-only
  |
AUDIT (.forge/AUDIT.md)         <- reality check + scar extraction
  |
SESSION PROMPTS                 <- spec + scars -> scoped work + gates
  |
AUTONOMOUS EXECUTION            <- agent builds, runs gates, reports
  |
HUMAN REVIEW                    <- reads verdict -> proceed / review / blocked
```

| Actor | Does | Does NOT |
|-------|------|----------|
| Orchestrator | Plans DAG, generates prompts, delegates to executor agents, manages state | Write project code |
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

### 2. Audit / Risk Assessment

**Brownfield (existing code):** Agent reads codebase, produces per-module verdicts:
KEEP / PATCH / REWRITE / DELETE / UNCERTAIN.
Extracts structured scars from discovered failures.

**Greenfield (new project):** Agent reads spec, projects risk per module:
SIMPLE / MODERATE / COMPLEX / RISKY.
Extracts scar seeds from projected failure modes.

### 3. Scar Loading

Concrete failure injection into session prompts. Each scar:

| Field | Format |
|-------|--------|
| ID | S{session}-{N}, A{N} (audit), or R{N} (risk) |
| Category | DATA-LOSS / SILENT-FAILURE / PERFORMANCE / CORRECTNESS / SECURITY / INTEGRATION / BUILD |
| Description | Concrete past or projected failure -- never abstract advice |
| Severity | CRITICAL / HIGH / MEDIUM / LOW |

**Loading priority:** CRITICAL always included. HIGH if relevant to this session's modules. MEDIUM from last two sessions only. LOW archived.

**Pruning (>6 sessions):** Retain last two sessions + all CRITICAL. Archive rest to `.forge/AUDIT-SCARS.md`.

### 4. Session Prompts

Self-contained execution cartridges carrying:
- Spec reference (exact version, e.g. `v1.2`)
- Deliverables from Build Order
- Scar load (priority-ordered)
- Discoveries forwarded from completed sessions
- Verification gates + quality gates
- Branch name + version tag (from Build Order)
- Autonomous execution instructions (agent runs everything, produces report)

### 5. Session DAG + Parallel Dispatch

Sessions declare `depends_on` in Build Order. Independent sessions run concurrently.

```
S1 -> S2a (parallel) -> S3 (merge) -> S4
       S2b (parallel) /
```

**Parallel dispatch:** Orchestrator spawns one executor Agent per independent session, each in its own worktree (branch isolation). All execute concurrently.

**Merge sessions:** After parallel tracks complete, a dedicated merge session integrates branches into `dev`. The merge session runs the full test suite as regression. Conflicts resolved during merge.

### 6. Autonomous Execution

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

### 7. Session Report + Human Action

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

### 8. Recovery + Spec Corrections

**Gate failure:** Agent attempts fix in current session, re-runs all gates. If fix-forward fails twice -> report BLOCKED with root cause.

**Test regression:** If this session caused it -> agent fixes forward. If pre-existing cause -> report BLOCKED with diagnosis.

**Spec is wrong:** Human adds addendum to TASKSPEC.md: original assumption, what reality revealed, corrected assumption, affected sessions. Version increments. Orchestrator regenerates affected prompts.

---

## Execution Flow

1. **Init** -- `forge init project-name` scaffolds `.forge/` structure with TASKSPEC template
2. **Spec** -- human writes `.forge/TASKSPEC.md` with Build Order (titles, branches, tags, DAG)
3. **Audit** -- orchestrator delegates audit (brownfield) or risk speculation (greenfield) to an agent. Scars extracted.
4. **Prompt** -- orchestrator generates session prompt from spec + audit + scars + prior discoveries
5. **Execute** -- orchestrator delegates prompt to executor agent. Agent works autonomously: build -> gates -> report. Parallel sessions dispatched concurrently via separate agents in worktree isolation.
6. **Report** -- agent produces session output ending with HUMAN ACTION verdict
7. **Review** -- human reads verdict. PROCEED -> merge branch to dev, tag, next prompt. REVIEW -> check flagged items. BLOCKED -> resolve issue.
8. **Repeat** until Build Order complete.

---

## Failure Modes

| Failure | Mitigation |
|---------|------------|
| Wrong spec | Human reviews spec before first session |
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
| Audit existing code | `forge audit` |
| Assess greenfield risk | `forge risk` |
| Generate session prompt | `forge prompt 1` |
| Run gates locally | `forge gate 1` |
| Merge and tag session | `forge merge 1` |
| Check project status | `forge status` |
| Add a scar | `forge scar add "description"` |
| Validate spec structure | `forge validate` |

For all templates, see `references/templates.md`.
