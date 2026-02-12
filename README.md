# TDD Agent Team

A Claude Code skill for running test-driven development with Agent Teams.

## What This Does

When you say `/tdd-team` or "spin up a TDD team", Claude will:

1. **Spawn a Tester teammate** - writes tests based on contracts, can't see implementation
2. **Spawn an Implementer teammate** - writes code based on contracts, can't see tests
3. **Act as the PM** - coordinates work, enforces rules, escalates to you via Slack

The team works from interface contracts you provide. The Tester and Implementer never see each other's code - they only communicate through the contract and the PM.

## Installation

### 1. Install the Skill (Global)

```bash
# Copy skill to your personal skills directory
cp -r skill ~/.claude/skills/tdd-team
```

The skill is now available in all your projects via `/tdd-team`.

### 2. Enable Agent Teams (Global)

Agent Teams is experimental. Enable it globally in `~/.claude/settings.json`:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

Or via environment variable if you prefer:
```bash
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
```

### 3. Configure Slack (Optional but Recommended)

The PM will notify you via Slack when decisions are needed.

```bash
# In each project where you use TDD teams:
echo "https://hooks.slack.com/services/YOUR/WEBHOOK/URL" > .slack-webhook-url
```

Get a webhook URL at: https://api.slack.com/messaging/webhooks

## Usage

### 1. Set Up Your Project

```bash
# Just add a contracts directory and .gitignore entries
mkdir contracts
echo ".slack-webhook-url" >> .gitignore
echo ".tdd/" >> .gitignore
```

Or copy the project template:
```bash
cp -r project-template/* /path/to/your/project/
```

### 2. Write a Contract

Create `contracts/my-feature.contract.md`. See `skill/templates/contract.md` for the format.

Example:
```markdown
# Contract: UserService

## 2.1 createUser

createUser(email: string, name: string) -> User

**Returns:** User object with id, email, name, createdAt

**Errors:**
- InvalidEmailError: when email format is invalid
- DuplicateEmailError: when email already exists
```

### 3. Spin Up the Team

```bash
cd /path/to/your/project
claude
```

Then:
```
/tdd-team
```

### Targeting Specific Contracts

```bash
# All contracts in contracts/
/tdd-team

# Specific contract by name
/tdd-team user-service

# Different directory (for monorepos)
/tdd-team packages/auth/contracts/

# Specific file in submodule
/tdd-team packages/auth/contracts/auth.contract.md
```

When targeting a submodule, the team creates `src/`, `tests/`, and `decisions/` relative to that location.

### 4. Let It Run

The team will:
- Tester writes failing tests based on the contract
- Implementer makes tests pass
- PM coordinates and notifies you via Slack when needed

You'll get Slack messages when:
- A decision is needed that only you can make
- The contract is ambiguous
- Work is blocked
- Work is complete

## How It Works

```
         You
          │
          │ "spin up a TDD team"
          ▼
    ┌───────────┐
    │ Claude    │ (Team Lead / PM)
    │           │
    │ - Spawns teammates
    │ - Creates tasks
    │ - Enforces rules
    │ - Notifies via Slack
    └─────┬─────┘
          │
    ┌─────┴─────┐
    ▼           ▼
┌───────┐   ┌───────────┐
│Tester │   │Implementer│
│       │   │           │
│ Reads:│   │ Reads:    │
│ - contracts/         │
│       │   │           │
│Writes:│   │ Writes:   │
│- tests│   │ - src/    │
│       │   │           │
│CAN'T: │   │ CAN'T:    │
│- src/ │   │ - tests/  │
└───────┘   └───────────┘
```

## The Rules

1. **Contract is king** - both teammates work only from what the contract specifies
2. **Lane discipline** - Tester can't read `src/`, Implementer can't read `tests/`
3. **Justified changes** - contract modifications require valid reasons (testability, impossibility, security)
4. **PM arbitrates** - disputes get resolved by checking the contract; ambiguities escalate to you

## File Structure

**The Skill** (`~/.claude/skills/tdd-team/`):
```
tdd-team/
├── SKILL.md              # Main instructions for Claude
├── prompts/
│   ├── tester.md         # Tester teammate prompt
│   └── implementer.md    # Implementer teammate prompt
├── templates/
│   └── contract.md       # Contract format template
└── scripts/
    └── notify-user.sh    # Slack notification script
```

**Your Project** (any existing structure):
```
your-project/
├── contracts/            # Your interface contracts (or wherever you put them)
│   └── *.contract.md
├── .slack-webhook-url    # Your Slack webhook (gitignored)
├── .tdd/                 # TDD process state (gitignored)
│   └── decisions/        # Rationale for contract changes
│       └── <contract-name>/
└── ... existing src/tests structure ...
```

The team discovers your existing project structure for tests and implementation - it doesn't impose one.

**Monorepo**:
```
monorepo/
├── .slack-webhook-url
├── .tdd/
│   └── decisions/
├── packages/
│   ├── auth/
│   │   └── contracts/
│   │       └── auth.contract.md
│   └── billing/
│       └── contracts/
│           └── billing.contract.md
```

For monorepos, run `/tdd-team packages/auth/contracts/` to work on a specific module.

## Tips

- **Write minimal contracts** - specify what to test, not how to implement
- **Be explicit about errors** - vague error specs cause disputes
- **Check decisions/** - past rulings persist across sessions
- **Trust the process** - back-and-forth between teammates is expected

## Troubleshooting

**"/tdd-team" not found:**
- Verify skill is installed: `ls ~/.claude/skills/tdd-team/SKILL.md`

**Team doesn't spawn:**
- Check Agent Teams is enabled in settings
- Try: `export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`

**No Slack notifications:**
- Check `.slack-webhook-url` exists in project root
- Test: `~/.claude/skills/tdd-team/scripts/notify-user.sh "test"`

**Teammates violating rules:**
- Tell Claude: "The Tester is reading src/, enforce the rules"
