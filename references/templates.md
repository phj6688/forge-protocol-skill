# FORGE v2 -- Templates Reference

All templates used by the FORGE protocol. Copy and adapt per project.

---

## TASKSPEC.md Template

```markdown
# [PROJECT NAME] -- TASKSPEC

## Provenance
| Field | Value |
|-------|-------|
| Date | YYYY-MM-DD |
| Codebase State | greenfield / brownfield |
| Audit Date | YYYY-MM-DD |
| Orchestrator | Claude / Human / [name] |
| FORGE Version | 2.0 |
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
[Full tree]

## Data Model
[Schemas, tables, types, relationships]

## Features

### Feature 1: [Name]
**Behavior:** [What it does]
**API Contract:** [Endpoints, signatures]
**Edge Cases:** [What could go wrong]
**Acceptance Criteria:** [How to know it works -- these become Session 0 tests]

### Feature 2: [Name]
[Same structure]

## Failure Handling
| Failure | Detection | Response | Recovery |
|---------|-----------|----------|----------|
| | | | |

## Environment Variables
| Variable | Purpose | Default |
|----------|---------|---------|
| | | |

## Build Order

### Session 0: Test Scaffolding
**Depends on:** []
**Deliverables:**
- [ ] Test files for all features derived from acceptance criteria
- [ ] All tests runnable and failing (red phase)
- [ ] Integration test shells from failure handling table

**Verify:**
\`\`\`bash
# All test files exist and run (expect failures)
npm test 2>&1 | grep -c "failing"
\`\`\`

**Quality Gates:** N/A
**Context Budget:** ~[estimate] tokens
**Scar Load:** None (first session)
**Regression:** N/A

### Session 1: [Title]
**Depends on:** [0]
**Deliverables:**
- [ ] Item 1
- [ ] Item 2

**Verify:**
\`\`\`bash
# command that must pass
\`\`\`

**Quality Gates:**
\`\`\`bash
# BLOCK: security lint
npm audit --audit-level=high
# WARN: test coverage
npm test -- --coverage 2>&1 | grep "All files"
\`\`\`

**Context Budget:** ~[estimate] tokens
**Scar Load:**
- [Structured scar: ID | Category | Description | Severity]

**Regression:** Session 0 tests still run

### Session 2a: [Title -- parallel track A]
**Depends on:** [1]
**Deliverables:**
- [ ] Item 1

**Verify / Quality Gates / Context Budget / Scar Load / Regression:** [same structure]

### Session 2b: [Title -- parallel track B]
**Depends on:** [1]
[Same structure -- independent of 2a]

### Session 3: [Title -- merge point]
**Depends on:** [2a, 2b]
[Same structure -- regression includes 0, 1, 2a, 2b]

## Addendum
[Reserved for spec corrections during execution. Each addendum increments spec version.]
```

---

## SESSION-PROMPT.md Template

```markdown
# Session [N] -- [Project Name]

**Spec:** TASKSPEC.md v[X.Y]
**Spec Addendums applied:** [list or "none"]
**Previous sessions completed:** [1..N-1 status, per dependency chain]
**Dependencies:** [session IDs this depends on]

## Mission (This Session)
[What this session accomplishes]

## Deliverables
- [ ] Deliverable 1
- [ ] Deliverable 2

## Context Budget
| Component | Estimated Tokens |
|-----------|-----------------|
| This prompt | ~X,XXX |
| Working room | ~X,XXX |
| Safety margin (20%) | ~X,XXX |
| **Total** | ~X,XXX / [model limit] |

## Scar Load

### Critical / Permanent (always loaded)
| ID | Category | Description | Severity |
|----|----------|-------------|----------|
| | | | CRITICAL |

### From Audit/Risk Report (relevant to this session's modules)
| ID | Category | Description | Severity |
|----|----------|-------------|----------|

### From Prior Sessions
| ID | Category | Description | Severity |
|----|----------|-------------|----------|

### Archived (see AUDIT-SCARS.md)
[Count] low-severity scars archived. Review if working in related modules.

## Discoveries from Prior Sessions
- [Session X discovered: "..."]
- [Session Y discovered: "..."]

## Constraints
[From CLAUDE.md and spec]

## Anti-Patterns
- DO NOT: [specific thing] -- INSTEAD: [correct approach]

## Verification Gates (Functional)
\`\`\`bash
# Gate 1: [description]
command_here
# Expected: [output]

# Gate 2: [description]
command_here
# Expected: [output]
\`\`\`

## Quality Gates (Non-Functional)
\`\`\`bash
# BLOCK: [description]
command_here
# Threshold: [value]

# WARN: [description]
command_here
# Threshold: [value]
\`\`\`

## Regression Gates (DAG ancestors only)
\`\`\`bash
# Session 0 gates
[commands]

# Session 1 gates
[commands]
\`\`\`

## Completion Checklist
- [ ] All deliverables implemented
- [ ] Confidence report written
- [ ] Session output report written
- [ ] All verification gates pass
- [ ] All quality gates checked (BLOCK pass, WARN logged)
- [ ] All regression gates pass
- [ ] Diff audit clean (no scope creep, no debug artifacts)
- [ ] No TODO/FIXME/HACK left behind
- [ ] Changes committed to feature branch
- [ ] Session tagged: forge/session-N-passed
```

---

## SESSION-OUTPUT.md Template

```markdown
# Session Output Report -- Session [N]

**Status:** PASSED / FAILED / ROLLED-BACK
**Spec Version:** TASKSPEC.md v[X.Y]
**Date:** YYYY-MM-DD
**Git Tag:** forge/session-N-passed

## Deliverables Completed
- [x] Deliverable 1
- [x] Deliverable 2
- [ ] Deliverable 3 (deferred to session N+1 -- reason: [X])

## Gate Results
| Gate | Type | Level | Result | Notes |
|------|------|-------|--------|-------|
| [gate 1] | VERIFY | BLOCK | PASS | |
| [gate 2] | VERIFY | BLOCK | PASS | |
| [gate 3] | QUALITY | BLOCK | PASS | |
| [gate 4] | QUALITY | WARN | WARN | "[detail]" |
| [regress S1] | REGRESSION | BLOCK | PASS | |

## Confidence Report
### Overall Confidence: HIGH / MEDIUM / LOW

### Per-Deliverable Assessment
| Deliverable | Confidence | Concern |
|-------------|-----------|---------|
| [deliverable 1] | HIGH | None |
| [deliverable 2] | MEDIUM | "[specific concern]" |

### Uncertainty Flags
- [Area where the agent is unsure]

### Discovered Risks (not in original spec)
- [New risk found during implementation]

### Suggested Scars for Next Session
| Category | Description | Suggested Severity |
|----------|-------------|--------------------|
| | | |

## Discoveries (facts for future sessions, NOT scars)
- "[Factual finding relevant to future sessions]"

## Deviations from Spec
- "[What changed and why]"

## Open Questions for Human (MUST resolve before next session)
- "[Question that must be resolved]"

## New Scars (from failures/near-misses)
| ID | Category | Description | Severity | Weight | Source |
|----|----------|-------------|----------|--------|--------|

## Diff Summary
- Files added: [count]
- Files modified: [count]
- Files deleted: [count]
- Lines: +[added] / -[removed]
```

---

## AUDIT.md Template

```markdown
# Audit Report -- [Project Name]

**Date:** YYYY-MM-DD
**Auditor:** [name]
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
- **Reason:** [why]
- **Failure:** [what breaks if left as-is]

## Structured Scar Extraction
| ID | Category | Description | Severity | Weight | Source |
|----|----------|-------------|----------|--------|--------|
| A1 | [category] | [concrete failure] | CRITICAL/HIGH/MEDIUM/LOW | [10/7/4/1] | [file/module] |

## Recommendations
- [Action items]
```

---

## RISK-SPECULATION.md Template (Greenfield)

```markdown
# Risk Speculation Report -- [Project Name]

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
- **Risk Level:** SIMPLE / MODERATE / COMPLEX / RISKY
- **Rationale:** [why this risk level]
- **Projected Failure Modes:** [what could go wrong]
- **Mitigation:** [how to reduce risk]
- **Anti-Patterns:** [what NOT to do]

## Integration Risk Matrix
[Which modules interact and where failures compound]

## Structured Scar Seeds
| ID | Category | Description | Severity | Weight | Source |
|----|----------|-------------|----------|--------|--------|
| R1 | [category] | [predicted failure] | [severity] | [weight] | risk-speculation |

## Recommended Session DAG
[Dependency graph showing which sessions can parallelize]
```

---

## CLAUDE.md Template (Project Rules)

```markdown
# Project Rules

## Commands
- Dev: [command]
- Test: [command]
- Typecheck: [command]
- Lint: [command]
- Build: [command]
- DB: [command]

## Code Style
[Language-specific rules]

## Non-Negotiable Rules
- No raw DB errors exposed to clients
- URLs from env vars, never hardcoded
- No console.log in committed code
- Secrets in .env only
- Feature branches only
- Tests before commits

## Known Gotchas
[Project-specific pitfalls]

## FORGE Protocol v2
- Spec: TASKSPEC.md (versioned, append-only)
- Audit: AUDIT.md
- Session 0: test scaffolding before implementation
- Sessions: sessions/ (DAG-ordered, parallel where independent)
- Gates: verification (functional) + quality (non-functional)
- Scars: structured schema with category/severity/weight
- Recovery: rollback protocol with git tags (forge/session-N-passed)
- Output: session output report with discoveries + confidence

## Session Hygiene
- /compact at ~50% context
- /clear between sessions
- Verify with grep, not memory
- Tag passing sessions: forge/session-N-passed
- Confidence report mandatory after every session
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
[Specific: file, function, line]

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
## ADDENDUM -- SPEC CORRECTION [YYYY-MM-DD] (v1.X)

### Original Assumption
### What Reality Revealed
### Corrected Assumption
### Affected Sessions
### Affected Modules
### Spec Version: v1.[X-1] -> v1.X
```

---

## AUDIT-SCARS.md Template (Archived Scars)

```markdown
# Archived Scar History -- [Project Name]

**Last Pruned:** YYYY-MM-DD

**Pruning Policy:** N-2 and N-1 scars stay active. CRITICAL never pruned. Everything else archived here.

## Archived from Session [X]
| ID | Category | Description | Severity | Original Session |
|----|----------|-------------|----------|-----------------|

## Archived from Session [Y]
| ID | Category | Description | Severity | Original Session |
|----|----------|-------------|----------|-----------------|
```

---

## Standard Quality Gates Reference

Adapt per project. Each gate is BLOCK or WARN level.

```bash
# BLOCK: Security lint (no high/critical vulns)
npm audit --audit-level=high

# WARN: Response time regression (>1.5x = warn, >2x = block)
curl -w "%{time_total}" -o /dev/null -s http://localhost:3000/api/health

# WARN: Bundle/binary size (>10% growth from last session)
du -sh dist/ | awk '{print $1}'

# WARN: Dependency count (flag new additions)
cat package.json | jq '.dependencies | length'

# WARN: Code quality (new lint warnings)
npm run lint 2>&1 | tail -1

# WARN: Test coverage (dropped from last session)
npm run test -- --coverage 2>&1 | grep "All files"

# BLOCK: No hardcoded secrets
grep -r "API_KEY\|SECRET\|PASSWORD" src/ --include="*.ts" -l | grep -v ".env"
```
