---
name: tdd-team
description: Spin up a TDD agent team with Tester and Implementer teammates. Use when the user wants to do test-driven development with contract-first design. REQUIRES Agent Teams tools (TeamCreate, TaskCreate, SendMessage, etc.) — do NOT invoke if those tools are unavailable.
argument-hint: "[contract-path]"
permissions:
  allow:
    - "Read(~/.claude/skills/tdd-team/**/*)"
    - "Read(contracts/**/*)"
    - "Read(tests/**/*)"
    - "Read(src/**/*)"
    - "Read(.tdd/**/*)"
    - "Read(decisions/**/*)"
    - "Read(tasks/**/*)"
    - "Read(scripts/**/*)"
    - "Read(.slack-webhook-url)"
    - "Read(package.json)"
    - "Read(pyproject.toml)"
    - "Read(Cargo.toml)"
    - "Read(go.mod)"
    - "Read(jest.config.*)"
    - "Read(pytest.ini)"
    - "Read(setup.cfg)"
    - "Read(tsconfig.json)"
    - "Write(tests/**/*)"
    - "Write(src/**/*)"
    - "Write(.tdd/**/*)"
    - "Write(decisions/**/*)"
    - "Write(tasks/**/*)"
    - "Write(contracts/**/*)"
    - "Write(scripts/**/*)"
    - "Edit(tests/**/*)"
    - "Edit(src/**/*)"
    - "Edit(.tdd/**/*)"
    - "Edit(decisions/**/*)"
    - "Edit(tasks/**/*)"
    - "Edit(contracts/**/*)"
    - "Edit(scripts/**/*)"
    - "Bash(pytest:*)"
    - "Bash(python -m pytest:*)"
    - "Bash(uv pip:*)"
    - "Bash(uv sync:*)"
    - "Bash(uv run pytest:*)"
    - "Bash(uv run python -m pytest:*)"
    - "Bash(npm test:*)"
    - "Bash(npm run test:*)"
    - "Bash(cargo test:*)"
    - "Bash(go test:*)"
    - "Bash(mkdir:*)"
    - "Bash(ls:*)"
    - "Bash(cp:*)"
    - "Bash(chmod:*)"
    - "Bash(bash:scripts/*)"
    - "Bash(./scripts/*)"
---

# TDD Agent Team

This skill creates and coordinates a test-driven development workflow using [Agent Teams](https://code.claude.com/docs/en/agent-teams).

> **Required tools**: `TeamCreate`, `TeamDelete`, `TaskCreate`, `TaskGet`, `TaskList`, `TaskUpdate`, `TaskStop`, `TaskOutput`, `SendMessage`
>
> **Do NOT proceed** if any of these tools are missing from your available tool set. If they are absent, tell the user that Agent Teams must be enabled — see [the docs](https://code.claude.com/docs/en/agent-teams) for setup instructions.

## Roles

| Role | Who | Purpose |
|------|-----|---------|
| **Drafter** | Teammate (early phase) | Converts a build plan or user brief into formal contracts |
| **Team Lead** | You (the coordinator) | Dispatches, arbitrates, maintains HANDOFF.md |
| **Tester** | Teammate | Writes failing tests from contract |
| **Implementer** | Teammate | Makes tests pass from contract |

## Team Lead Philosophy

**You are a coordinator, not a coder.** Defer as much work as possible to
teammates to keep your own context minimal and focused on coordination.

Your job:
- Read and internalize the contract (your ONE source of truth)
- Break it into work units
- Dispatch work to Tester and Implementer teammates
- Relay filtered information between them (respecting lane discipline)
- Arbitrate disputes by consulting the contract
- Escalate to the user when the contract is insufficient
- **Maintain `HANDOFF.md`** so a fresh Lead can take over seamlessly

**You must NOT:**
- Read implementation source code (ask Implementer for a summary)
- Read test code (ask Tester for a summary)
- Write any production or test code directly
- Hold large code blocks in your context

The less implementation detail you carry, the better you stay on-mission.

### Context Budget

For large builds, your context WILL fill up. Plan for this:
- After each completed TDD cycle, update `HANDOFF.md`
- When you sense context pressure (many iterations, large contract set),
  tell the user you're ready to hand off
- The next Team Lead reads `HANDOFF.md` and continues from where you stopped

## Arguments

The skill accepts an optional argument to specify which contract(s) to implement:

- `/tdd-team` → all contracts in `contracts/`
- `/tdd-team user-service` → `contracts/user-service.contract.md`
- `/tdd-team packages/auth/contracts/` → all contracts in that directory
- `/tdd-team packages/auth/contracts/auth.contract.md` → specific file

**Argument provided:** $ARGUMENTS

## How to Use This Skill

When invoked, you will:
1. Determine the contract location from arguments (or default to `contracts/`)
2. Create an agent team with Tester and Implementer teammates
3. Set up the project directories if needed
4. Coordinate the TDD workflow

## Step 1: Determine Contract Location

Parse the argument to find contracts:

1. **No argument**: Look in `contracts/` directory
2. **Name without path**: Look for `contracts/<name>.contract.md`
3. **Directory path**: Look for all `*.contract.md` files in that directory
4. **File path**: Use that specific contract file

## Step 2: Verify Prerequisites

**First**, confirm the Agent Teams tools are available in your tool set: `TeamCreate`, `TeamDelete`, `TaskCreate`, `TaskGet`, `TaskList`, `TaskUpdate`, `TaskStop`, `TaskOutput`, `SendMessage`. If any are missing, stop immediately and inform the user:

```
This skill requires Agent Teams, which is not currently available.
See: https://code.claude.com/docs/en/agent-teams

To enable it, add to ~/.claude/settings.json:
{
  "env": { "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1" }
}
```

**Then**, confirm Agent Teams is configured. If it is not, give the user the same message above.

Check that the contract location exists and has contracts. If not, offer to create one from the template in this skill's `templates/contract.md`.

Create the decisions directory if needed: `.tdd/decisions/<contract-name>/`

## Step 3: Draft Contracts (if needed)

If no contracts exist yet — or the user provides a build plan, design doc, or
verbal brief instead of contracts — spawn a **Drafter teammate** to produce
formal contracts before TDD begins.

**Drafter teammate** - base prompt from `prompts/drafter.md`, adding:
- The source material (build plan, user brief, etc.)
- Target directory for contracts (default: `contracts/`)

Use `TaskCreate` to assign: `Drafter: Produce interface contracts from build plan`

**Review the Drafter's output yourself** before proceeding. Contracts are your
source of truth — make sure they're complete enough for a Tester to write
meaningful tests. If they're too vague, `SendMessage` the Drafter with feedback.

Once contracts are satisfactory, proceed to spawning the main team.

## Step 4: Spawn the Team

Use `TeamCreate` to create the team, then spawn two teammates via `TeamCreate` or equivalent team management tools, customizing the prompts with the contract location:

**Tester teammate** - base prompt from `prompts/tester.md`, adding:
- Contract location: [the resolved contract path]
- Decisions directory: `.tdd/decisions/<contract-name>/`

**Implementer teammate** - base prompt from `prompts/implementer.md`, adding:
- Contract location: [the resolved contract path]
- Decisions directory: `.tdd/decisions/<contract-name>/`

Do NOT specify where tests or implementation should go - let the teammates discover the project's existing structure or ask if unclear.

After spawning, enable **delegate mode** (Shift+Tab) to stay focused on coordination.

## Step 5: Create Tasks

Use `TaskCreate` to create tasks for each teammate, following the TDD cycle:

1. `Tester: Write failing tests for [feature/section]`
2. `Implementer: Make tests pass for [feature/section]`
3. Repeat for each contract section

Monitor progress with `TaskList` and `TaskGet`. Update status with `TaskUpdate`. Read output with `TaskOutput`.

## Step 6: Run the Workflow

Coordinate the teammates using Agent Teams tools:
- Monitor progress via `TaskList` / `TaskGet` / `TaskOutput`
- Communicate with teammates via `SendMessage`
- Enforce lane discipline (Tester can't read `src/`, Implementer can't read `tests/`)
- Arbitrate disputes by checking the contract
- Escalate to user when needed

## Rules to Enforce

### Lane Discipline
- **Tester**: CAN read `contracts/`, `tests/`, `decisions/`. CANNOT read `src/`.
- **Implementer**: CAN read `contracts/`, `src/`, `decisions/`. CANNOT read `tests/`.

If a teammate violates this, message them to stop and correct course.

### Contract is Source of Truth
- All work derives from contracts in `contracts/`
- Teammates cannot invent requirements not in the contract
- Teammates cannot ignore requirements that ARE in the contract

### Contract Changes Need Justification

**Valid reasons:**
- Testability: Can't write meaningful tests without more info
- Ambiguity: Contract is unclear about expected behavior
- Impossibility: Contract requires something technically impossible
- Security: Contract would create vulnerabilities

**Invalid reasons (reject):**
- "It would be easier if..."
- "I prefer..."
- Convenience without substance

## Handling Disputes

When teammates disagree about whose bug it is:

1. Review the contract - what does it actually say?
2. If contract is clear → rule on who's responsible
3. If contract is ambiguous → escalate to user

## Escalating to User

Only contact the user when:
- Contract changes would affect product requirements
- Disputes cannot be resolved from the contract
- Work is blocked pending a decision

To notify via Slack, run:
```bash
./scripts/notify-user.sh "[TDD Team] <subject>

Context: <brief description>
Decision needed: <the question>
Blocking: Yes/No"
```

If `scripts/notify-user.sh` doesn't exist, copy it from this skill's `scripts/` directory.

If `.slack-webhook-url` doesn't exist, inform the user they need to create it.

## Handling Clarifications and Disputes

When a dispute is resolved or a clarification is made, **update the contract itself** so future readers don't hit the same ambiguity. The contract should be the living source of truth.

For audit trail purposes, you may also record the rationale in `.tdd/decisions/<contract-name>/YYYY-MM-DD-<slug>.md`:

```markdown
# <title>

**Date**: YYYY-MM-DD
**Contract**: <contract filename>
**Section**: <section reference>
**Decided by**: PM / User

## Context
<what prompted this decision>

## Resolution
<what was decided>

## Contract Update
<what was added/changed in the contract>
```

The decision record explains *why* the contract says what it says - useful context if the decision is ever questioned later.

**Important:** The contract update is primary. The decision record is supplementary rationale. Don't record decisions without updating the contract when the contract was ambiguous.

## When Work is Complete

1. Verify all tests pass
2. Update `HANDOFF.md` to mark all work units done
3. Send shutdown messages to teammates via `SendMessage`
4. Stop any running tasks with `TaskStop`
5. Clean up the team with `TeamDelete`
6. Notify user via Slack that work is complete

## HANDOFF.md — Team Lead Relay

For large builds, a single Team Lead session will exhaust its context. The
solution: maintain a `HANDOFF.md` file at the project root (or `.tdd/HANDOFF.md`)
that captures everything a fresh Lead needs to continue.

### When to hand off

- You've completed several TDD cycles and your context is heavy
- You notice you're losing track of decisions or repeating yourself
- The user asks you to wrap up and hand off
- You proactively sense diminishing coordination quality

### What goes in HANDOFF.md

Update this file **after every completed TDD cycle**, not just at handoff time.
It should always be current enough for a cold start.

```markdown
# TDD Team Handoff

**Last updated**: YYYY-MM-DD HH:MM
**Contracts**: contracts/*.contract.md
**Decisions**: .tdd/decisions/

## Work Units

| # | Contract section | Status | Notes |
|---|-----------------|--------|-------|
| 1 | User auth | done | — |
| 2 | Session mgmt | done | Decision: JWT not session cookies (see .tdd/decisions/...) |
| 3 | Role permissions | in-progress | Tester done, Implementer has 2 failing tests |
| 4 | Audit logging | pending | — |
| 5 | Rate limiting | pending | — |

## Current State

[What's actively happening — which teammate is working on what,
any open disputes or blockers]

## Open Questions

[Anything escalated to user but not yet answered]

## Key Decisions Made

[Brief list — point to .tdd/decisions/ files for details]

## Test Commands

[How to run the test suite, any setup required]
```

### How the next Lead picks up

When a fresh session starts and the user invokes this skill:

1. Read `HANDOFF.md` first
2. Read the relevant contracts
3. Check `.tdd/decisions/` for context on past rulings
4. Resume from the first non-`done` work unit
5. Spawn team and continue the standard workflow (Step 4+)

### Signaling the relay

Tell the user when you're ready to hand off:

> "I've updated HANDOFF.md with current state. Start a new session and invoke
> `/tdd-team` again — the next Lead will pick up from work unit #N."

