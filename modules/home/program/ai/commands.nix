# Shared command categories for AI CLI permission rules.
#
# Each entry is a command prefix; individual CLIs wrap them in their own
# permission syntax (Claude Code turns them into `Bash(<prefix>:*)`, for
# example). Keeping the raw prefixes here lets other CLIs (aider, codex, ...)
# reuse the same allow/deny intent without coupling to one tool's format.
{
  # Read-only git subcommands. Mutating git (commit, push, reset, ...) is
  # intentionally omitted so it still requires approval.
  gitRead = [
    "git status"
    "git log"
    "git diff"
    "git show"
    "git grep"
    "git blame"
    "git rev-parse"
    "git rev-list"
    "git ls-files"
    "git ls-tree"
    "git for-each-ref"
    "git describe"
    "git reflog"
    "git shortlog"
    "git cat-file"
    "git merge-base"
    "git range-diff"
    "git diff-tree"
    "git count-objects"
    "git fsck"
    "git verify-commit"
    "git verify-tag"
    "git check-ignore"
    "git config --get"
    "git config --list"
    "git config --get-regexp"
    "git stash list"
    "git submodule status"
    "git worktree list"
    "git branch --list"
    "git branch -a"
    "git branch -r"
    "git branch --show-current"
    "git tag -l"
    "git tag --list"
    "git remote -v"
    "git remote show"
    "git remote get-url"
  ];

  # Git ops that clone, update, or roll back a repo without creating new work.
  # Used for the read-only reference directory; safe to auto-run (no commits).
  gitManage = [
    "git clone"
    "git fetch"
    "git pull"
    "git reset"
    "git checkout"
    "git restore"
    "git clean"
    "git switch"
  ];

  # Nix read / evaluate / build / cache-fetch. Profile mutation is denied
  # separately; store GC and lock-file updates are left to approval.
  nixAllowed = [
    "nix eval"
    "nix-instantiate"
    "nix derivation"
    "nix flake metadata"
    "nix flake show"
    "nix flake info"
    "nix flake list-inputs"
    "nix flake check"
    "nix build"
    "nix-build"
    "nix develop"
    "nix shell"
    "nix run"
    "nix search"
    "nix path-info"
    "nix log"
    "nix why-depends"
    "nix hash"
    "nix config show"
    "nix registry list"
    "nix store ls"
    "nix store cat"
    "nix store path-from-hash-part"
    "nix store ping"
    "nix store prefetch-file"
    "nix profile list"
    "nix profile history"
    "nix profile diff-closures"
  ];

  # Build tools: configure, build, run tests, clear build cache.
  buildTools = [
    "make"
    "cmake"
    "ctest"
    "meson"
    "ninja"
    "dotnet build"
    "dotnet restore"
    "dotnet clean"
    "dotnet test"
    "cargo build"
    "cargo check"
    "cargo test"
    "cargo clean"
    "cargo metadata"
    "go build"
    "go test"
    "go vet"
    "go list"
    "npm run build"
    "npm run lint"
    "npm test"
    "npm run test"
    "pnpm run build"
    "pnpm run lint"
  ];

  # Read-only inspection tools not covered by the built-in read-only set.
  readTools = [
    "jq"
    "rg"
    "file"
    "tree"
    "realpath"
    "readlink"
    "date"
    "uname"
    "id"
    "whoami"
    "printenv"
    "ps"
    "pgrep"
    "pstree"
    "free"
    "df"
    "lsblk"
    "lsusb"
    "lspci"
    "dmesg"
    "lsmod"
    "modinfo"
    "systemctl status"
    "systemctl is-enabled"
    "systemctl list-units"
    "systemctl list-unit-files"
    "systemctl show"
    "systemctl cat"
    "journalctl"
    "nixos-version"
  ];

  # Mutating nix profile operations to block outright.
  nixDeny = [
    "nix profile add"
    "nix profile install"
    "nix profile remove"
    "nix profile upgrade"
    "nix profile wipe-history"
  ];

  # Recursive deletes of user data. The leading `*` makes these substring
  # matches, so they also catch the command when it's buried inside a wrapper
  # like `nix shell ... -c "rm -rf ~"`. System/root paths are left alone:
  # Linux permissions block non-root users there, and nix-managed paths are
  # reproducible. Relative paths (`rm -rf build`) also stay promptable for
  # cache cleanup.
  dangerousDeny = [
    "*rm -rf ~*"
    "*rm -fr ~*"
    "*rm -rf /home*"
    "*rm -fr /home*"
  ];
}
