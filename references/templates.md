# FORGE v3 -- Templates Reference

All templates for FORGE protocol artifacts. Copy and adapt per project.

---

## TASKSPEC.md Template

```markdown
# [PROJECT NAME] -- TASKSPEC

## Provenance
| Field | Value |
|-------|-------|
| Date | YYYY-MM-DD |
| Codebase | greenfield / [git hash] |
| Spec Version | v1.0 |

## Mission
[One paragraph: what this project does and why it exists.]

## Stack
| Layer | Technology | Version | Rationale |
|-------|-----------|---------|-----------|
| Runtime | | | |
| Database | | | |
| Framework | | | |

## Directory Structure
[Full tree -- agent creates exactly this]

## Data Model
[Schemas, tables, types, relationships, constraints]

## Features

### Feature 1: [Name]
**Behavior:** [what it does]
**API Contract:** [endpoints, signatures, payloads]
**Edge Cases:** [what could go wrong]
**Acceptance Criteria:** [how to verify -- these drive test generation]

### Feature 2: [Name]
[Same structure]

## Failure Handling
| Failure | Detection | Response | Recovery |
|---------|-----------|----------|----------|

## Environment Variables
| Variable | Purpose | Default |
|----------|---------|---------|

## Build Order

### Session 1: [Title]
**Branch:** feat/[kebab-case-title]
**Tag:** v0.1.0
**Depends on:** []
**Deliverables:**
- [ ] Item 1
- [ ] Item 2
- [ ] Test infrastructure + tests for this session's deliverables

**Verification Gates:**
```bash
# [description of what this verifies]
[runnable command] # expected: [output]
```

**Quality Gates:**
```bash
# BLOCK: [description]
[command]
# WARN: [description]
[command]
```

### Session 2a: [Title -- parallel track A]
**Branch:** feat/[kebab-case-title]
**Tag:** v0.2.0
**Depends on:** [1]
**Deliverables:**
- [ ] Item 1

**Verification Gates / Quality Gates:** [same structure]

### Session 2b: [Title -- parallel track B]
**Branch:** feat/[kebab-case-title]
**Tag:** (tagged after merge session)
**Depends on:** [1]
[Same structure -- independent of 2a]

### Session 3: [Title -- merge]
**Branch:** (merges 2a + 2b into dev)
**Tag:** v0.3.0
**Depends on:** [2a, 2b]
**Deliverables:**
- [ ] Merge parallel branches, resolve conflicts
- [ ] Integration tests across merged code

**Verification Gates:** [full test suite]

## Addendum
[Reserved for spec corrections. Each addendum increments version. Original text above stays frozen.]
```

---

## SESSION-PROMPT.md Template

```markdown
# [Session Title] -- [Project Name]

**Spec:** TASKSPEC.md v[X.Y]
**Addendums applied:** [list or "none"]
**Completed sessions:** [titles of completed sessions]
**This session depends on:** [session titles]

## Mission
[What this session delivers -- 1-2 sentences]

## Deliverables
- [ ] Deliverable 1
- [ ] Deliverable 2
- [ ] Tests for all new functionality

## Branch + Tag
- Work on branch: `feat/[name]`
- After gates pass, this merges to `dev` and gets tagged `v[X.Y.Z]`

## Scar Load

### Critical (always loaded)
| ID | Category | Description |
|----|----------|-------------|

### From Audit/Risk (relevant to this session)
| ID | Category | Description | Severity |
|----|----------|-------------|----------|

### From Prior Sessions
| ID | Category | Description | Severity |
|----|----------|-------------|----------|

## Discoveries from Prior Sessions
- [Session title]: "[factual finding relevant to this work]"

## Constraints
[From CLAUDE.md and spec -- non-negotiable rules]

## Anti-Patterns
- DO NOT: [specific thing] -- INSTEAD: [correct approach]

## Verification Gates
Run these after implementation. All must pass.
```bash
# [description]
[command] # expected: [output]
```

## Quality Gates
```bash
# BLOCK: [description]
[command]

# WARN: [description]
[command]
```

## Regression
Run the full test suite. All tests must pass.
```bash
[test suite command]
```

## Autonomous Execution Instructions
1. Create branch `feat/[name]` from `dev`
2. Implement all deliverables
3. Write tests for new functionality
4. Run verification gates -- fix any failures
5. Run quality gates -- BLOCK must pass, log WARN results
6. Run full test suite -- fix any regressions
7. Commit with conventional messages (feat:/fix:/refactor: -- no session numbers, no FORGE terms)
8. Write session output report to .forge/sessions/[NN-name]/output.md
9. If fix-forward fails twice on any gate, report BLOCKED with root cause
```

---

## SESSION-OUTPUT.md Template

```markdown
# Session Output -- [Session Title]

**Status:** PASSED / FAILED
**Spec Version:** v[X.Y]
**Date:** YYYY-MM-DD
**Branch:** feat/[name]
**Tag:** v[X.Y.Z]

## Deliverables
- [x] Deliverable 1
- [x] Deliverable 2
- [ ] Deliverable 3 (deferred -- reason: [X])

## Gate Results
| Gate | Type | Level | Result | Notes |
|------|------|-------|--------|-------|
| [name] | VERIFY | BLOCK | PASS | |
| [name] | QUALITY | BLOCK | PASS | |
| [name] | QUALITY | WARN | WARN | [detail] |
| Test suite | REGRESSION | BLOCK | PASS | [N] tests, [N] passed |

## Confidence
| Deliverable | Level | Concern |
|-------------|-------|---------|
| [deliverable 1] | HIGH | -- |
| [deliverable 2] | MEDIUM | [specific concern] |

## Discoveries
- [Factual finding relevant to future sessions]

## Deviations from Spec
- [What diverged and why -- or "None"]

## New Scars
| ID | Category | Description | Severity |
|----|----------|-------------|----------|

## Human Action

**VERDICT:** PROCEED / REVIEW / BLOCKED

[If PROCEED]
All gates passed. Confidence HIGH across deliverables.
-> Merge `feat/[name]` to `dev`, tag `v[X.Y.Z]`.
-> Next: [session title]. Orchestrator can generate prompt.

[If REVIEW]
Gates passed but attention needed:
- [ ] Review: [specific area]
- [ ] Decide: [specific question]
Estimated review: ~[N] minutes.

[If BLOCKED]
Cannot proceed until resolved:
- [ ] [issue + root cause]
- [ ] [what must happen before retry]
```

---

## AUDIT.md Template

```markdown
# Audit Report -- [Project Name]

**Date:** YYYY-MM-DD
**Spec:** TASKSPEC.md v[X.Y]

## Summary
| Verdict | Count |
|---------|-------|
| KEEP | |
| PATCH | |
| REWRITE | |
| DELETE | |
| UNCERTAIN | |

## Module Verdicts

### [file/module path]
- **Verdict:** KEEP / PATCH / REWRITE / DELETE / UNCERTAIN
- **Reason:** [one sentence]
- **Failure:** [what breaks -- omit for KEEP]

## Scar Extraction
| ID | Category | Description | Severity |
|----|----------|-------------|----------|
| A1 | [category] | [concrete failure found] | CRITICAL/HIGH/MEDIUM/LOW |

## Recommendations
[Ordered: fix first, what blocks what, suggested session ordering]
```

---

## RISK-SPECULATION.md Template (Greenfield)

```markdown
# Risk Speculation -- [Project Name]

**Date:** YYYY-MM-DD
**Spec:** TASKSPEC.md v[X.Y]

## Summary
| Risk Level | Count |
|------------|-------|
| SIMPLE | |
| MODERATE | |
| COMPLEX | |
| RISKY | |

## Module Risk Assessment

### [Module Name]
- **Risk:** SIMPLE / MODERATE / COMPLEX / RISKY
- **Rationale:** [why]
- **Projected Failures:** [what could go wrong]
- **Mitigation:** [how to reduce risk]
- **Anti-Patterns:** [concrete things to avoid]

## Integration Risk Matrix
| Module A | Module B | Risk | Notes |
|----------|----------|------|-------|

## Scar Seeds
| ID | Category | Description | Severity |
|----|----------|-------------|----------|
| R1 | [category] | [projected failure] | [severity] |

## Recommended Session DAG
[Dependency graph with rationale for ordering]
```

---

## CLAUDE.md Template (Project Root)

```markdown
# [Project Name]
[One-liner description]

## Commands
- Dev: `[command]`
- Test: `[command]`
- Lint: `[command]`
- Build: `[command]`

## Code Style
[Language-specific rules]

## Rules
- No raw DB errors exposed to clients
- URLs from env vars only
- No debug logging in committed code
- Secrets in .env only
- Feature branches, merge to dev
- Tests before merge
```

---

## CORRECTIVE-PROMPT.md Template

```
STOP.

## Error
[Exact error output]

## Root Cause
[One sentence]

## Fix
[Specific: file, function, what to change]

## Verify
[Command that must pass]

## Constraints
- Do not touch anything else.
- Do not refactor surrounding code.
- Do not add features.
- Fix this one thing. Verify. Stop.
```

---

## ADDENDUM.md Template

```markdown
## Addendum -- v1.[X] (YYYY-MM-DD)

### Original Assumption
[What the spec said]

### What Reality Revealed
[What was discovered during implementation]

### Corrected Assumption
[The new truth]

### Affected Sessions
[Which sessions need regenerated prompts]

### Affected Modules
[Which parts of the codebase are impacted]
```

---

## AUDIT-SCARS.md Template (Archived)

```markdown
# Archived Scars -- [Project Name]

**Last Pruned:** YYYY-MM-DD
**Policy:** Last two sessions + CRITICAL stay active. Everything else archived here.

## Archived from [Session Title]
| ID | Category | Description | Severity | Origin |
|----|----------|-------------|----------|--------|

## Archived from [Session Title]
| ID | Category | Description | Severity | Origin |
|----|----------|-------------|----------|--------|
```

---

## Standard Quality Gates Reference

Adapt per project. Each gate is BLOCK or WARN level.

```bash
# BLOCK: security lint
npm audit --audit-level=high

# BLOCK: type safety
npx tsc --noEmit

# BLOCK: no hardcoded secrets
grep -rn "API_KEY\|SECRET\|PASSWORD" src/ --include="*.ts" -l | grep -v ".env" | wc -l  # expect: 0

# WARN: bundle/binary size
du -sh dist/ | awk '{print $1}'

# WARN: dependency count change
jq '.dependencies | length' package.json

# WARN: test coverage
npm test -- --coverage 2>&1 | grep "All files"

# WARN: lint warnings
npm run lint 2>&1 | tail -1
```
