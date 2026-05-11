# Global Scars -- Cross-Project Failure Patterns

These scars apply to ALL forge sessions regardless of project. Load them alongside project-specific scars when generating session prompts.

---

## GS-1: Binary bytes in source files cause invisible test failures

| Field | Value |
|-------|-------|
| ID | GS-1 |
| Category | BUILD |
| Severity | HIGH |
| Origin | klub PR #1, May 2026 |

**Failure:** A test file (`safe-json-ld.test.ts`) contained a literal NUL byte (0x00) as a test fixture constant. Git classified the entire file as binary. The PR showed "Binary files differ" with no visible diff, and reviewers couldn't verify the security-critical test existed or ran. CI may silently skip binary-classified test files.

**Root cause:** The agent used a raw byte literal (`'\x00'` stored as actual 0x00 in the file) instead of `String.fromCharCode(0x0000)` which produces the same value at runtime but keeps the source file as clean UTF-8.

**Prevention rules:**
1. Never embed raw NUL (0x00), BOM, or control characters directly in source files.
2. Use runtime construction for binary test fixtures: `String.fromCharCode()`, `Buffer.from()`, ` ` escape sequences in code (not literal bytes on disk).
3. When a session produces test files that exercise binary/control-character handling, the verification gate MUST include: `file <test-file> | grep -q "text"` to confirm git won't classify it as binary.
4. Every project SHOULD have a `.gitattributes` forcing `*.ts text diff`, `*.tsx text diff`, etc. If one doesn't exist, the first session that creates test files must add it.
5. After committing, run `git diff --stat HEAD~1` and confirm test files show line counts, not "Bin 0 -> N bytes".

---

## GS-2: Spec-drift from requirement docs causes wasted sessions

| Field | Value |
|-------|-------|
| ID | GS-2 |
| Category | SPEC-DRIFT |
| Severity | HIGH |
| Origin | klub KLB-22, May 2026 |

**Failure:** A TASKSPEC was written from a Linear story that said `pnpm eval`, assumed `AI_PLATFORM_GUIDE.md` didn't exist, used `@@map` for Prisma naming, assumed timestamp-based migration names, and didn't account for a dummy `OPENAI_API_KEY` in CI. All five assumptions were wrong. The spec was v1.0, session prompts were generated, and the mismatches were only caught during a manual plan review. Without that review, executor agents would have produced code that didn't match project conventions.

**Root cause:** The protocol went straight from spec to audit without verifying the spec's assumptions against the actual codebase. Requirements from external systems (Linear, Jira, PRDs) contain stale or generic assumptions that don't reflect current code state.

**Prevention rules:**
1. Always run Discovery (`forge discover`) between spec and audit for brownfield/hybrid projects.
2. For every file path the spec says "create", check if it already exists.
3. For every tool/command the spec references (pnpm, yarn, pytest), verify which tool the project actually uses.
4. For every naming convention the spec assumes (migration format, model naming, script naming), read the last 3 examples in the codebase.
5. For every CI env var the spec relies on, read the actual CI workflow file and note dummy values.
6. Treat requirement docs as claims. Discovery turns claims into verified facts.
