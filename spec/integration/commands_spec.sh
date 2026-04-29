# shellcheck shell=bash

Describe 'nvg commands'
  # Path to the nvg script
  nvg() {
    "$PROJECT_ROOT/bin/nvg" "$@"
  }

  Describe 'nvg version'
    It 'returns version number'
      When call nvg version
      The status should be success
      The output should include "nvg v"
    End

    It 'accepts --version flag'
      When call nvg --version
      The status should be success
      The output should include "nvg v"
    End

    It 'accepts -v flag'
      When call nvg -v
      The status should be success
      The output should include "nvg v"
    End
  End

  Describe 'nvg help'
    It 'shows help message'
      When call nvg help
      The status should be success
      The output should include "USAGE"
      The output should include "COMMANDS"
    End

    It 'accepts --help flag'
      When call nvg --help
      The status should be success
      The output should include "USAGE"
    End

    It 'shows help when no command given'
      When call nvg
      The status should be success
      The output should include "USAGE"
    End

    It 'lists all commands'
      When call nvg help
      The output should include "run"
      The output should include "install"
      The output should include "uninstall"
      The output should include "config"
      The output should include "init"
      The output should include "cache"
    End

    It 'shows --ci option in help'
      When call nvg help
      The output should include "--ci"
      The output should include "CI mode"
    End
  End

  Describe 'nvg init'
    setup() {
      TEMP_DIR=$(mktemp -d)
      cd "$TEMP_DIR"
    }

    cleanup() {
      cd /
      rm -rf "$TEMP_DIR"
    }

    BeforeEach 'setup'
    AfterEach 'cleanup'

    It 'creates .nvg config file'
      When call nvg init
      The status should be success
      The output should be present
      The path ".nvg" should be file
    End

    It 'config file contains PROVIDER'
      nvg init > /dev/null
      The contents of file ".nvg" should include "PROVIDER"
    End

    It 'config file contains FILE_PATTERNS'
      nvg init > /dev/null
      The contents of file ".nvg" should include "FILE_PATTERNS"
    End

    It 'config file contains EXCLUDE_PATTERNS'
      nvg init > /dev/null
      The contents of file ".nvg" should include "EXCLUDE_PATTERNS"
    End

    It 'config file contains RULES_FILE'
      nvg init > /dev/null
      The contents of file ".nvg" should include "RULES_FILE"
    End

    It 'config file contains STRICT_MODE'
      nvg init > /dev/null
      The contents of file ".nvg" should include "STRICT_MODE"
    End
  End

  Describe 'nvg config'
    setup() {
      TEMP_DIR=$(mktemp -d)
      cd "$TEMP_DIR"
    }

    cleanup() {
      cd /
      rm -rf "$TEMP_DIR"
    }

    BeforeEach 'setup'
    AfterEach 'cleanup'

    It 'shows configuration'
      When call nvg config
      The status should be success
      The output should include "Configuration"
    End

    It 'shows provider not configured when no config'
      When call nvg config
      The output should include "Not configured"
    End

    It 'shows provider when configured'
      echo 'PROVIDER="claude"' > .nvg
      When call nvg config
      The output should include "claude"
    End

    It 'shows rules file status'
      When call nvg config
      The output should include "Rules File"
    End
  End

  Describe 'nvg install'
    setup() {
      TEMP_DIR=$(mktemp -d)
      cd "$TEMP_DIR"
      git init --quiet
    }

    cleanup() {
      cd /
      rm -rf "$TEMP_DIR"
    }

    BeforeEach 'setup'
    AfterEach 'cleanup'

    It 'creates pre-commit hook'
      When call nvg install
      The status should be success
      The output should be present
      The path ".git/hooks/pre-commit" should be file
    End

    It 'hook contains nvg run command'
      nvg install > /dev/null
      The contents of file ".git/hooks/pre-commit" should include "nvg run"
    End

    It 'hook is executable'
      nvg install > /dev/null
      The path ".git/hooks/pre-commit" should be executable
    End

    It 'fails if not in git repo'
      rm -rf .git
      When call nvg install
      The status should be failure
      The output should include "Not a git repository"
    End
  End

  Describe 'nvg uninstall'
    setup() {
      TEMP_DIR=$(mktemp -d)
      cd "$TEMP_DIR"
      git init --quiet
      nvg install > /dev/null
    }

    cleanup() {
      cd /
      rm -rf "$TEMP_DIR"
    }

    BeforeEach 'setup'
    AfterEach 'cleanup'

    It 'removes pre-commit hook'
      When call nvg uninstall
      The status should be success
      The output should be present
      The path ".git/hooks/pre-commit" should not be exist
    End

    It 'succeeds if hook does not exist'
      rm .git/hooks/pre-commit
      When call nvg uninstall
      The status should be success
      The output should be present
    End
  End

  Describe 'nvg cache'
    setup() {
      TEMP_DIR=$(mktemp -d)
      cd "$TEMP_DIR"
      git init --quiet
      echo "rules" > AGENTS.md
      echo 'PROVIDER="claude"' > .nvg
    }

    cleanup() {
      cd /
      rm -rf "$TEMP_DIR"
    }

    BeforeEach 'setup'
    AfterEach 'cleanup'

    Describe 'nvg cache status'
      It 'shows cache status'
        When call nvg cache status
        The status should be success
        The output should include "Cache Status"
      End
    End

    Describe 'nvg cache clear'
      It 'clears project cache'
        When call nvg cache clear
        The status should be success
        The output should include "Cleared cache"
      End
    End

    Describe 'nvg cache clear-all'
      It 'clears all cache'
        When call nvg cache clear-all
        The status should be success
        The output should include "Cleared all cache"
      End
    End

    Describe 'invalid subcommand'
      It 'fails for unknown cache subcommand'
        When call nvg cache invalid
        The status should be failure
        The output should include "Unknown cache command"
      End
    End
  End

  Describe 'unknown command'
    It 'fails with error message'
      When call nvg unknown-command
      The status should be failure
      The output should include "Unknown command"
    End
  End
End
