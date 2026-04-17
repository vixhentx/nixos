{ config, lib, pkgs, ... }:
let
  histdbFile = "${config.xdg.stateHome}/zsh/history.db";
  sqliteBin = lib.getExe pkgs.sqlite;
in

{
  home.packages = [ pkgs.sqlite ];

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      filter_mode = "global";
      filter_mode_shell_up_key_binding = "directory";
      search_mode = "fuzzy";
      style = "compact";
      inline_height = 20;
      workspaces = true;
      search.filters = [
        "global"
        "workspace"
        "directory"
        "session"
        "host"
      ];
    };
  };

  programs.zsh = {
    enable = true;
    dotDir = config.home.homeDirectory;
    enableCompletion = true;
    autosuggestion = {
      enable = true;
      strategy = [ ];
    };
    syntaxHighlighting.enable = true;
    history = {
      path = "${config.xdg.stateHome}/zsh/history";
      size = 50000;
      save = 50000;
      append = true;
      extended = true;
      expireDuplicatesFirst = true;
      findNoDups = true;
      ignoreAllDups = true;
      saveNoDups = true;
    };
    historySubstringSearch = {
      enable = true;
      searchUpKey = [ "^P" ];
      searchDownKey = [ "^N" ];
    };

    oh-my-zsh = {
      enable = true;
      theme = "jonathan";
      plugins = [
        "git"
        "aliases"
        "extract"
        "zsh-interactive-cd"
        "python"
        "docker"
        "docker-compose"
        "encode64"
        "debian"
        "git-commit"
        "dotnet"
        "direnv"
      ];
    };

    shellAliases = {
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../../";
      c = "clear";
      cat = "bat";
      g = "git";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      lg = "lazygit";
      pager = "nvimpager";
      less = "nvimpager";
      more = "nvimpager";
      el = "eza -lh --git";
      ela = "eza -lah --git";
      et = "eza --tree --level=2";
      gitcat = "git ls-files -z | xargs -0 bat --style=header --decorations=always";
    };

    initContent = lib.mkMerge [
      (lib.mkOrder 640 ''
        export HISTDB_FILE="${histdbFile}"
        mkdir -p "${config.xdg.stateHome}/zsh"

        # Clean up any half-initialized histdb file left by earlier failures,
        # then bootstrap a valid schema so histdb won't try a broken 0 -> 2 migration.
        if [[ -e "$HISTDB_FILE" ]]; then
          _histdb_table_count="$(${sqliteBin} -batch -noheader "$HISTDB_FILE" \
            "select count(*) from sqlite_master where type='table' and name in ('commands', 'places', 'history');" \
            2>/dev/null || echo 0)"
          if [[ "$_histdb_table_count" != "3" ]]; then
            rm -f -- "$HISTDB_FILE" "$HISTDB_FILE-wal" "$HISTDB_FILE-shm"
          fi
          unset _histdb_table_count
        fi

        if [[ ! -e "$HISTDB_FILE" ]]; then
          ${sqliteBin} -batch "$HISTDB_FILE" <<'EOF'
create table commands (id integer primary key autoincrement, argv text, unique(argv) on conflict ignore);
create table places   (id integer primary key autoincrement, host text, dir text, unique(host, dir) on conflict ignore);
create table history  (id integer primary key autoincrement,
                       session int,
                       command_id int references commands (id),
                       place_id int references places (id),
                       exit_status int,
                       start_time int,
                       duration int);
PRAGMA user_version = 2;
EOF
        fi
      '')

      (lib.mkOrder 650 ''
        source ${pkgs.zsh-histdb}/share/zsh-histdb/sqlite-history.zsh
      '')

      (lib.mkOrder 710 ''
        # Prefer suggestions that are common in the current directory tree,
        # then fall back to global histdb preferences and normal completion.
        _zsh_histdb_ready() {
          [[ -n ''${_ZSH_HISTDB_READY-} ]] && return 0
          _histdb_init >/dev/null 2>&1 || return 1
          typeset -g _ZSH_HISTDB_READY=1
        }

        _zsh_autosuggest_strategy_histdb_top_here() {
          _zsh_histdb_ready || return 1
          local query="
            select commands.argv
            from history
            left join commands on history.command_id = commands.rowid
            left join places on history.place_id = places.rowid
            where places.dir like '$(sql_escape $PWD)%'
              and commands.argv like '$(sql_escape $1)%'
            group by commands.argv
            order by count(*) desc
            limit 1
          "
          suggestion=$(_histdb_query "$query" 2>/dev/null)
        }

        _zsh_autosuggest_strategy_histdb_top() {
          _zsh_histdb_ready || return 1
          local query="
            select commands.argv
            from history
            left join commands on history.command_id = commands.rowid
            left join places on history.place_id = places.rowid
            where commands.argv like '$(sql_escape $1)%'
            group by commands.argv, places.dir
            order by places.dir != '$(sql_escape $PWD)', count(*) desc
            limit 1
          "
          suggestion=$(_histdb_query "$query" 2>/dev/null)
        }

        ZSH_AUTOSUGGEST_STRATEGY=(
          histdb_top_here
          histdb_top
          history
          completion
        )
      '')

      (lib.mkOrder 1000 (builtins.readFile ./utils.zsh))
    ];

    sessionVariables = {
      HISTDB_FILE = histdbFile;
      PAGER = "nvimpager";
      MANPAGER = "nvimpager";
    };
  };
}
