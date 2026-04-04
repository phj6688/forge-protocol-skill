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
version: 2.0.0
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash, Agent]
---

# FORGE v2 -- Agent Delegation Protocol

**Fixed-spec, Output-gated, Regression-anchored, Gate-enforced Execution**

*Shape it once. Strike until it holds.*

FORGE delegates software tasks to Claude Code agents across multiple sessions. It solves:

- **Context decay** -- immutable spec loaded into every session prompt
- **Compounding rot** -- verification gates block progression until pass
- **Regression blindness** -- session N re-verifies all ancestor sessions

**Critical constraint:** FORGE guarantees derivation integrity, not spec correctness. If the spec is wrong, FORGE builds the wrong thing -- correctly and repeatably.

---

## ARCHITECTURE (6 Layers)

1. **CANONICAL SPEC** (TASKSPEC.md) -- versioned, append-only ground truth
2. **AUDIT REPORT** (AUDIT.md) -- reads reality, produces structured verdicts
3. **SESSION 0** -- test scaffolding generated from spec before any implementation
4. **SESSION PROMPTS** -- spec + audit + scar loading -> scoped work + gates
5. **EXECUTION** -- agent builds, verifies, reports confidence, produces session output
6. **HUMAN CHECKPOINT** -- verify gates + quality gates + diff audit -> approve next

**Three-Actor Topology:** Orchestrator (plans/generates prompts) | Human (IS the loop) | Executor (builds/verifies/self-assesses)

---

## THE TWELVE COMPONENTS

### 1. Canonical Spec with Versioning (TASKSPEC.md)

Append-only. Initial = **v1.0**. Each addendum increments: v1.1, v1.2. Session prompts reference exact version. Contains: provenance, mission, stack, directory structure, data model, features (with acceptance criteria), failure handling, env vars, build order (session DAG), addendum section.

Session count: `N = ceil(total_features / (context_budget x 0.6))`

### 2. Audit Report (AUDIT.md)

Per-file verdicts: KEEP / PATCH / REWRITE / DELETE / UNCERTAIN. Greenfield uses **Risk Speculation** (RISK-SPECULATION.md) with levels: SIMPLE / MODERATE / COMPLEX / RISKY.

### 3. Session 0 -- Test-First Scaffolding

Before any implementation, generate test skeletons from spec acceptance criteria. Tests must run and fail (red phase). The executor cannot weaken tests to match its own output if tests existed first. Session 0 has no scars, no implementation deliverables. Gate: all tests exist, run, and fail.

### 4. Structured Scar Loading

Concrete failure injection into session prompts. Each scar is a structured record:

| Field | Values |
|-------|--------|
| ID | S{session}-{number} or A{number} (audit) |
| Category | DATA-LOSS, SILENT-FAILURE, PERFORMANCE, CORRECTNESS, SECURITY, INTEGRATION, BUILD |
| Description | Concrete failure, never abstract |
| Severity | CRITICAL (weight 10) / HIGH (7) / MEDIUM (4) / LOW (1) |
| Source | audit, risk-speculation, session-N, regression-failure |

**Context-aware loading:** If scar load exceeds 15% of context budget: load all CRITICAL, then HIGH relevant to this session's modules, then MEDIUM from N-1/N-2 only, drop LOW with reference to AUDIT-SCARS.md.

**Pruning (>8 sessions):** Keep N-2 and N-1 active. CRITICAL never pruned. Archive rest.

### 5. Session Prompts with Context Budget

Self-contained cartridges carrying: CONTEXT (spec version), DELIVERABLES, SCAR LOAD (structured, priority-ordered), DISCOVERIES (from prior sessions), ANTI-PATTERNS, VERIFY (functional gates), QUALITY GATES (non-functional), REGRESSION (DAG-aware ancestors), CONTEXT BUDGET estimate.

**Budget rule:** Prompt + working room + 20% margin must not exceed 80% of model context. Split session if over.

### 6. Verification Gates (Functional)

Discrete, human-executed, scoped, pre-defined. Where possible, gates run Session 0 tests. At 15% per-session failure, unverified 5-session project = 56% cumulative failure.

### 7. Quality Gates (Non-Functional)

Second tier. Two levels: **BLOCK** (must pass) and **WARN** (log + human decides). Standard gates: response time, bundle size, dependency count, security lint, code quality, test coverage. Quality gates complement verification gates -- "works" vs "works well."

### 8. Regression Enforcement (DAG-Aware)

Session N re-verifies **ancestor sessions** per the dependency DAG. Linear chain: session 4 regresses 1,2,3. DAG: session 4 regresses only its transitive `depends_on` ancestors.

### 9. Session Dependency DAG

Sessions declare `depends_on` in Build Order. Independent sessions run in parallel on separate branches. Merge session resolves conflicts. Scar loading in parallel sessions includes shared ancestors but NOT sibling sessions.

Example:
```
S0 -> S1 -> S2a (parallel) -> S3 (merge) -> S4
              S2b (parallel) /
```

### 10. Regression Recovery Protocol

Decision tree:
- **<20 lines changed:** Fix forward with STOP format. Re-run ALL gates.
- **>20 lines, current session caused it:** Fix forward in current session.
- **>20 lines, deeper cause:** Rollback to `forge/session-{N-1}-passed` git tag. Regenerate session prompt with new scar.
- **Fix-forward fails twice:** Escalate to rollback.

Every session that passes gates gets tagged: `forge/session-N-passed`. Every regression failure MUST produce a scar (HIGH+ severity).

### 11. Agent Confidence Report

Mandatory after every session. Structure: overall confidence (HIGH/MEDIUM/LOW), per-deliverable assessment with concerns, uncertainty flags, discovered risks not in spec, suggested scars. LOW confidence = human MUST review before running gates. Not a gate itself -- a signal amplifier for human review.

### 12. Session Output Report & Diff Audit

Each session produces a Session Output Report: status, spec version, deliverables completed, gate results, confidence report, discoveries (facts for future sessions -- NOT scars), deviations from spec, open questions (MUST resolve before next session), new scars, diff summary.

**Diff audit** (post-execution, pre-gate): review `git diff forge/session-{N-1}-passed..HEAD`. Checklist: all changes relevant, no scope creep, no debug artifacts, no secrets, changes align with spec.

---

## EXECUTION PROTOCOL (8 Steps)

1. **Write the Spec** -- TASKSPEC.md v1.0 with session DAG in Build Order
2. **Run the Audit** -- brownfield: file verdicts + structured scars; greenfield: risk speculation + scar seeds
3. **Session 0** -- test scaffolding from acceptance criteria. Tag `forge/session-0-passed`
4. **Generate Session Prompts** -- spec version, structured scars by priority, discoveries, quality gates, context budget. Split if over 80%
5. **Execute** -- sequential or parallel per DAG. Each session on feature branch. `/compact` at 50%. Agent produces confidence report
6. **Post-Session Audit & Gates** -- session output report -> diff audit -> verification gates -> quality gates -> regression gates -> tag `forge/session-N-passed`
7. **Correct Errors** -- STOP format for mid-session fixes. Regression Recovery Protocol for regression failures
8. **Handle Spec-Rot** -- addendum + version increment, never edit original

For all templates, see `references/templates.md`.

---

## FAILURE MODES

| Failure | Symptom | Mitigation |
|---------|---------|------------|
| Spec incorrectness | Correct build of wrong thing | Human reviews spec before session 0 |
| Audit false KEEP | Broken code survives | Second-pass on UNCERTAIN verdicts |
| Scar accumulation | Prompt bloat | Structured scars with weight + context-aware loading |
| Gate theater | Gates always pass | Session 0 tests are independent; gates test behavior |
| Derivation drift | Prompt diverges from spec | Spec versioning -- prompts reference exact version |
| Spec-rot | Spec assumes wrong thing | Addendum protocol with version increment |
| Regression cascade | Session N breaks session 1 | Recovery Protocol: fix-forward or rollback |
| Context blowout | Agent loses coherence | Context budget accounting; split oversized sessions |
| Knowledge loss | Next session repeats mistakes | Session Output Report transfers discoveries forward |
| Blind review | Human approves without understanding | Diff audit + confidence report surface where to look |
| Parallel merge conflict | Independent sessions collide | Own branches per parallel session; merge session resolves |
| Test bias | Agent writes tests matching its bugs | Session 0 generates tests before implementation |

---

## WORKFLOW GUIDE

### Starting a new project:
1. Write TASKSPEC.md v1.0 -- ask about mission, stack, features, data model
2. Define session dependency DAG in Build Order
3. Set up: `sessions/` dir, CLAUDE.md, settings
4. Run audit or risk speculation with structured scar extraction
5. Execute Session 0: test scaffolding from acceptance criteria
6. Generate Session 1 prompt with context budget

### Continuing an existing project:
1. Read TASKSPEC.md (check version) + prior session outputs
2. Resolve any open questions from last session output
3. Load discoveries from prior sessions
4. Generate next prompt: structured scars, quality gates, context budget
5. After execution: confidence report -> diff audit -> all gates

### Regression failure:
1. Follow Recovery Protocol decision tree (Component 10)
2. <20 lines = fix forward; >20 lines = assess; fix-forward fails twice = rollback
3. Generate scar from the failure

### Spec correction:
1. Addendum -- never modify original
2. Increment version (v1.X -> v1.X+1)
3. Document: original assumption, reality, correction, affected sessions

### Session too large:
1. Check context budget estimate
2. Split into sub-sessions with own DAG edges
3. Regenerate prompts

### Key behaviors:
- Structured scars loaded by priority (CRITICAL first)
- Never skip regression gates
- Session prompts reference exact spec version
- Confidence reports mandatory -- LOW = human must review
- Session output reports transfer discoveries forward
- Tag every pass: `forge/session-N-passed`
- `/compact` at 50%, `/clear` between sessions
- Open questions MUST resolve before next session
