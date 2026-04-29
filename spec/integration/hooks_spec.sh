# shellcheck shell=bash

Describe 'Git hooks install/uninstall'
  
  setup() {
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR" || exit 1
    git init --quiet
    git config user.email "test@test.com"
    git config user.name "Test User"
    # Get the path to nvg from the spec directory
    NVG_BIN="$PROJECT_ROOT/bin/nvg"
  }

  cleanup() {
    cd /
    rm -rf "$TEMP_DIR"
  }

  BeforeEach 'setup'
  AfterEach 'cleanup'

  Describe 'cmd_install'
    It 'creates hook with markers in fresh repo'
      "$NVG_BIN" install >/dev/null 2>&1
      The path ".git/hooks/pre-commit" should be file
      The contents of file ".git/hooks/pre-commit" should include "# ======== NVG START ========"
      The contents of file ".git/hooks/pre-commit" should include "nvg run || exit 1"
      The contents of file ".git/hooks/pre-commit" should include "# ======== NVG END ========"
    End

    It 'appends to existing hook with markers'
      mkdir -p .git/hooks
      cat > .git/hooks/pre-commit << 'EOF'
#!/usr/bin/env bash
echo "existing hook"
EOF
      chmod +x .git/hooks/pre-commit
      
      "$NVG_BIN" install >/dev/null 2>&1
      
      The contents of file ".git/hooks/pre-commit" should include "existing hook"
      The contents of file ".git/hooks/pre-commit" should include "# ======== NVG START ========"
      The contents of file ".git/hooks/pre-commit" should include "nvg run || exit 1"
    End

    It 'does not duplicate if already installed'
      "$NVG_BIN" install >/dev/null 2>&1
      "$NVG_BIN" install >/dev/null 2>&1
      
      # Count occurrences of NVG START
      count=$(grep -c "NVG START" .git/hooks/pre-commit)
      The value "$count" should eq "1"
    End

    It 'uses git-path hooks for hook path (worktree compatible)'
      # The hook should be installed at $(git rev-parse --git-path hooks)/
      # This correctly resolves to main repo's hooks even in worktrees
      "$NVG_BIN" install >/dev/null 2>&1
      
      hooks_dir=$(git rev-parse --git-path hooks)
      The path "$hooks_dir/pre-commit" should be file
    End

    It 'inserts before exit 0 in existing hook'
      mkdir -p .git/hooks
      cat > .git/hooks/pre-commit << 'EOF'
#!/bin/sh
echo "other hook logic"
exit 0
EOF
      chmod +x .git/hooks/pre-commit
      
      "$NVG_BIN" install >/dev/null 2>&1
      
      # NVG should appear BEFORE the final exit 0
      # Get line numbers
      nvg_line=$(grep -n "NVG START" .git/hooks/pre-commit | cut -d: -f1)
      exit_line=$(grep -n "^exit 0" .git/hooks/pre-commit | tail -1 | cut -d: -f1)
      
      # NVG line should be less than exit line (appears before)
      The value "$nvg_line" should be present
      The value "$exit_line" should be present
      # Assert NVG comes before exit - using test command with assertion
      Assert [ "$nvg_line" -lt "$exit_line" ]
    End

    It 'creates commit-msg hook with --commit-msg flag'
      "$NVG_BIN" install --commit-msg >/dev/null 2>&1
      The path ".git/hooks/commit-msg" should be file
      The path ".git/hooks/pre-commit" should not be exist
      The contents of file ".git/hooks/commit-msg" should include "# ======== NVG START ========"
      The contents of file ".git/hooks/commit-msg" should include 'nvg run "$1" || exit 1'
      The contents of file ".git/hooks/commit-msg" should include "# ======== NVG END ========"
    End

    It 'commit-msg hook passes commit message file to nvg run'
      "$NVG_BIN" install --commit-msg >/dev/null 2>&1
      # The hook should have "$1" to pass the commit message file
      The contents of file ".git/hooks/commit-msg" should include '"$1"'
    End

    It 'pre-commit hook does NOT have $1 argument'
      "$NVG_BIN" install >/dev/null 2>&1
      # pre-commit hook should use simple "nvg run" without $1
      The contents of file ".git/hooks/pre-commit" should include "nvg run || exit 1"
      The contents of file ".git/hooks/pre-commit" should not include '"$1"'
    End
  End

  Describe 'cmd_uninstall'
    It 'removes NVG-only hook file completely'
      "$NVG_BIN" install >/dev/null 2>&1
      "$NVG_BIN" uninstall >/dev/null 2>&1
      
      The path ".git/hooks/pre-commit" should not be exist
    End

    It 'removes only NVG section from mixed hook'
      mkdir -p .git/hooks
      cat > .git/hooks/pre-commit << 'EOF'
#!/usr/bin/env bash
echo "existing hook"
EOF
      chmod +x .git/hooks/pre-commit
      
      "$NVG_BIN" install >/dev/null 2>&1
      "$NVG_BIN" uninstall >/dev/null 2>&1
      
      The path ".git/hooks/pre-commit" should be file
      The contents of file ".git/hooks/pre-commit" should include "existing hook"
      The contents of file ".git/hooks/pre-commit" should not include "NVG START"
      The contents of file ".git/hooks/pre-commit" should not include "nvg run"
    End

    It 'handles legacy hooks without markers'
      mkdir -p .git/hooks
      cat > .git/hooks/pre-commit << 'EOF'
#!/usr/bin/env bash
# NuevoViruz Guardian
nvg run || exit 1
EOF
      chmod +x .git/hooks/pre-commit
      
      "$NVG_BIN" uninstall >/dev/null 2>&1
      
      The path ".git/hooks/pre-commit" should not be exist
    End

    It 'removes commit-msg hook when installed with --commit-msg'
      "$NVG_BIN" install --commit-msg >/dev/null 2>&1
      "$NVG_BIN" uninstall >/dev/null 2>&1
      
      The path ".git/hooks/commit-msg" should not be exist
    End

    It 'removes both hooks if both are installed'
      # Install both hooks (edge case - maybe user ran install twice with different flags)
      "$NVG_BIN" install >/dev/null 2>&1
      "$NVG_BIN" install --commit-msg >/dev/null 2>&1
      
      The path ".git/hooks/pre-commit" should be file
      The path ".git/hooks/commit-msg" should be file
      
      "$NVG_BIN" uninstall >/dev/null 2>&1
      
      The path ".git/hooks/pre-commit" should not be exist
      The path ".git/hooks/commit-msg" should not be exist
    End
  End
End
