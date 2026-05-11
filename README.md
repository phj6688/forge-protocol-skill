# FORGE Protocol

**Autonomous agent delegation for spec-driven software projects.**

*Shape it once. Strike until it holds.*

FORGE turns a single specification into a graph of autonomous build sessions. Agents derive, build, verify, and report. Humans review verdicts -- not diffs, not gates, not branches.

It solves four failure modes of long-running AI-assisted builds:

| Problem | FORGE's answer |
|---|---|
| **Context decay** -- agents forget the plan | Spec is re-loaded into every session prompt |
| **Compounding rot** -- bugs cascade across sessions | Verification + quality gates block progression |
| **Regression blindness** -- fixes break prior work | The full test suite runs as the regression anchor |
| **Spec-drift** -- spec doesn't match codebase reality | Discovery verifies assumptions before agents execute |

---

## Flow

```mermaid
flowchart LR
    classDef spec fill:#1e3a5f,stroke:#4a9eff,color:#fff,stroke-width:2px
    classDef discover fill:#1e5a4a,stroke:#4affce,color:#fff,stroke-width:2px
    classDef audit fill:#5a3a1e,stroke:#ff9e4a,color:#fff,stroke-width:2px
    classDef exec fill:#1e5a3a,stroke:#4aff9e,color:#fff,stroke-width:2px
    classDef gate fill:#5a1e3a,stroke:#ff4a9e,color:#fff,stroke-width:2px
    classDef human fill:#3a1e5a,stroke:#9e4aff,color:#fff,stroke-width:2px

    SPEC["TASKSPEC.md<br/>ground truth"]:::spec
    DISCOVER["DISCOVERY.md<br/>spec vs reality"]:::discover
    AUDIT["AUDIT.md<br/>scars + risks"]:::audit
    PROMPT["Session prompt<br/>spec + discovery + scars"]:::spec
    AGENT["Executor agent<br/>build + test"]:::exec
    GATES["Verification<br/>+ quality gates"]:::gate
    REPORT["Session report<br/>PROCEED / REVIEW / BLOCKED"]:::human
    HUMAN(["Human review"]):::human
    MERGE["Merge to dev<br/>tag vX.Y.Z"]:::exec

    SPEC -->|verify| DISCOVER
    DISCOVER -->|amend if needed| SPEC
    SPEC -->|load v1.x| PROMPT
    DISCOVER -->|codebase context| PROMPT
    AUDIT -->|inject scars| PROMPT
    SPEC -->|derive| AUDIT
    PROMPT -->|delegate| AGENT
    AGENT -->|runs| GATES
    GATES -->|pass / fail| REPORT
    REPORT --> HUMAN
    HUMAN -->|PROCEED| MERGE
    HUMAN -.->|BLOCKED: fix spec| SPEC
    MERGE -.->|next session| PROMPT
```

All workflow artifacts live in `.forge/` (gitignored). Git history shows only feature commits -- no session numbers, no protocol terms.

---

## Install

```bash
git clone git@github.com:phj6688/forge-protocol-skill.git
cd forge-protocol-skill
./install.sh
```

This symlinks `bin/forge` into `~/.local/bin/forge` and ensures the directory is on your `$PATH`.

Verify:

```bash
forge version
```

To use as an agent skill, copy `SKILL.md` and `references/` into your agent's skills directory under a `forge-protocol/` folder.

---

## Usage

```bash
forge init my-project      # scaffold .forge/
# edit .forge/TASKSPEC.md   -- define mission, stack, Build Order
forge discover             # verify spec assumptions against codebase
# review .forge/DISCOVERY.md -- amend TASKSPEC if corrections found
forge audit                # brownfield: verdicts + scars from existing code
forge risk                 # greenfield: projected risks + scar seeds
forge prompt 1             # generate session 1 prompt
# delegate the prompt to an executor agent -- it builds, tests, reports
forge merge 1              # merge feature branch to dev, tag vX.Y.Z
forge prompt 2             # next session
forge status               # DAG progress
```

---

## Project layout

```
forge-protocol-skill/
├── SKILL.md                    agent skill definition (v3.1)
├── bin/forge                   CLI tool
├── install.sh                  symlinks bin/forge to ~/.local/bin
├── examples/
│   └── TASKSPEC-example.md     reference spec (NullDrift signal engine)
└── references/
    ├── templates.md            TASKSPEC, DISCOVERY, AUDIT, session prompt templates
    └── global-scars.md         cross-project failure patterns
```

When you run `forge init`, the target project gets:

```
my-project/
└── .forge/                     (gitignored)
    ├── TASKSPEC.md             canonical spec, append-only
    ├── DISCOVERY.md            spec-vs-reality verification
    ├── AUDIT.md                audit or risk report
    ├── state.json              DAG progress
    └── sessions/
        └── 01-data-layer/
            ├── prompt.md
            └── output.md
```

---

## Principles

1. **Spec-driven.** Everything derives from `TASKSPEC.md`. Agents derive, never guess.
2. **Ground truth first.** Before agents execute, the spec is verified against the actual codebase. Requirements from external sources are claims, not facts.
3. **Autonomous execution.** Agents build, run gates, produce reports. Humans review results only.
4. **Invisible workflow.** Git history looks human-built. FORGE artifacts never reach the repo.
5. **Feature-oriented git.** Branches and tags describe *what* was built, not *which session* built it.
6. **Test suite as regression.** The test suite verifies prior work. No gate replay.

---

## License

MIT.
