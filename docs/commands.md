# Commands

> 📖 Back to [README](../README.md)

Full command reference for NuevoViruz Guardian.

---

## Commands Table

| Command                     | Description                                               | Example                         |
| --------------------------- | --------------------------------------------------------- | ------------------------------- |
| `init`                      | Create sample `.nvg` config file                          | `nvg init`                      |
| `install`                   | Install git pre-commit hook (default)                     | `nvg install`                   |
| `install --commit-msg`      | Install git commit-msg hook (for commit message validation) | `nvg install --commit-msg`    |
| `uninstall`                 | Remove git hooks from current repo                        | `nvg uninstall`                 |
| `run`                       | Run code review on staged files                           | `nvg run`                       |
| `run --ci`                  | Run code review on last commit (for CI/CD)                | `nvg run --ci`                  |
| `run --pr-mode`             | Review all files changed in the full PR                   | `nvg run --pr-mode`             |
| `run --pr-mode --diff-only` | PR review with diffs only (faster, cheaper)               | `nvg run --pr-mode --diff-only` |
| `run --no-cache`            | Run review ignoring cache                                 | `nvg run --no-cache`            |
| `config`                    | Display current configuration and status                  | `nvg config`                    |
| `cache status`              | Show cache status for current project                     | `nvg cache status`              |
| `cache clear`               | Clear cache for current project                           | `nvg cache clear`               |
| `cache clear-all`           | Clear all cached data                                     | `nvg cache clear-all`           |
| `help`                      | Show help message with all commands                       | `nvg help`                      |
| `version`                   | Show installed version                                    | `nvg version`                   |

---

## Command Details

### `nvg init`

Creates a sample `.nvg` configuration file in your project root with sensible defaults.

```bash
$ nvg init
✅ Created config file: .nvg
```

---

### `nvg install`

Installs a git hook that automatically runs code review on every commit.

**Default (pre-commit hook):**

```bash
$ nvg install
✅ Installed pre-commit hook: .git/hooks/pre-commit
```

**With commit message validation (commit-msg hook):**

```bash
$ nvg install --commit-msg
✅ Installed commit-msg hook: .git/hooks/commit-msg
```

The `--commit-msg` flag installs a commit-msg hook instead of pre-commit. This allows NVG to also validate your commit message (e.g., conventional commits format, issue references, etc.). The commit message is automatically included in the AI review.

If a hook already exists, NVG will append to it rather than replacing it.

---

### `nvg uninstall`

Removes the git pre-commit hook from your repository.

```bash
$ nvg uninstall
✅ Removed pre-commit hook
```

---

### `nvg run [--no-cache]`

Runs code review on currently staged files. Uses intelligent caching by default to skip unchanged files.

```bash
$ git add src/components/Button.tsx
$ nvg run
# Reviews the staged file (uses cache)

$ nvg run --no-cache
# Forces review of all files, ignoring cache
```

---

### `nvg config`

Shows the current configuration, including where config files are loaded from and all settings.

```bash
$ nvg config

Current Configuration:

Config Files:
  Global:  Not found
  Project: .nvg

Values:
  PROVIDER:          claude
  FILE_PATTERNS:     *.ts,*.tsx,*.js,*.jsx
  EXCLUDE_PATTERNS:  *.test.ts,*.spec.ts
  RULES_FILE:        AGENTS.md
  STRICT_MODE:       true
  TIMEOUT:           300s
  PR_BASE_BRANCH:    auto-detect

Rules File: Found
```

---

## 🚫 Bypass Review

Sometimes you need to commit without review:

```bash
# Skip pre-commit hook entirely
git commit --no-verify -m "wip: work in progress"

# Short form
git commit -n -m "hotfix: urgent fix"
```
