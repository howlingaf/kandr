#!/usr/bin/env bash
# Generic build-and-run watcher. Copy into a project and edit TARGETS.
#
# K&R: every .c file is its own program (bin/<name>). `all` builds them all,
# so a broken exercise shows up immediately; RUN names the one to execute
# after a successful build -- change it as you move between exercises, or
# run ./watcher.sh -t to only build.
#
# Each TARGET is  name | make target | run command [| guard]. The run
# command may be empty (build only); the optional guard is a command that
# must succeed for the target to be attempted at all (e.g. "tests exist"),
# otherwise it's reported as skipped. Fields are split on '|', so commands
# can't contain a pipe or '||' (use if/then or a script instead). Then:
#
#   ./watcher.sh            # the prod target
#   ./watcher.sh -t         # the test target
#   ./watcher.sh -a         # both, prod first (what nvim auto-starts)
#
# On any failure (compile error, failing test, crash) the screen is cleared
# and the full output is printed under a FAILED header (scroll back for the
# top of it; the output is also kept in $log). Re-runs on any save in the
# repo (inotifywait; pacman -S inotify-tools).

# ---- per-project config ----------------------------------------------------
RUN=main   # which program the prod target runs after building
TARGETS=(
    "prod | all | if [ -x bin/$RUN ]; then echo \"--- ./$RUN ---\"; ./bin/$RUN; else echo \"(no bin/$RUN -- set RUN= in watcher.sh)\"; fi"
    "test | all | true"
)
# Files the build itself writes; changes to these must not retrigger. `tags`
# is rewritten by nvim's ctags hook on every save.
IGNORE='(^|/)(bin|tags)(/|$)|\.(o|swp)$|~$'
# ---------------------------------------------------------------------------

log=${TMPDIR:-/tmp}/watcher-$(basename "$PWD").log

step() {
    "$@" >"$log" 2>&1
    local rc=$?
    if (( rc == 0 )); then
        cat "$log"
    else
        # No clear here: run_pass already cleared and printed the header,
        # which is the receipt -- clearing again would wipe it.
        echo "=============== FAILED (exit $rc): $* ==============="
        cat "$log"
        echo "=============== end of output ($(wc -l <"$log") lines) -- also in $log ==============="
    fi
    return $rc
}

run_target() {
    local name=$1 mk=$2 cmd=$3 guard=$4
    echo "=============== $name ==============="
    if [[ -n $guard ]] && ! eval "$guard" >/dev/null 2>&1; then
        echo "(skipped: $guard failed)"
        return 0
    fi
    step make -j "$mk" || return
    [[ -n $cmd ]] && step bash -c "$cmd"
}

case ${1:-} in
    '')   selected=(prod) ;;
    -t)   selected=(test) ;;
    -a)   selected=(prod test) ;;
    *)    echo "usage: $0 [-t | -a]   (default: prod; -t: test; -a: both)" >&2; exit 2 ;;
esac
want() { local s; for s in "${selected[@]}"; do [[ $s == "$1" ]] && return 0; done; return 1; }

# Inside an nvim terminal, ask nvim to put this pass's header on the top
# line of the window (custom/term.lua scroll_to_marker), so long output is
# read from the top instead of the tail. No-op outside nvim.
show_top() {
    [[ -n $NVIM ]] || return 0
    sleep 0.1   # let nvim render the last of the output first
    command nvim --server "$NVIM" --remote-expr \
        "v:lua.require('custom.term').scroll_to_marker($$, '### ')" >/dev/null 2>&1
}

# Source files whose mtime the receipt below considers -- the things a build
# actually depends on. Widen for other languages.
SOURCES='\.(c|h|cc|cpp|cxx|hpp|hh|lox)$|(^|/)(Makefile|makefile)$'

# Newest source mtime, as "HH:MM:SS name". Printed in the header so the
# screen carries proof of WHICH state of the tree it was built from: if this
# is older than the file you just saved, the output is stale. (mtime is the
# kernel's "contents last modified" stamp -- what make compares to decide
# what needs rebuilding.)
newest_source() {
    git ls-files -co --exclude-standard 2>/dev/null \
    | grep -E "$SOURCES" \
    | grep -Ev "$IGNORE" \
    | xargs -r -d '\n' stat -c '%Y %n' 2>/dev/null \
    | sort -rn | head -1 \
    | while read -r epoch name; do
        printf '%s %s' "$(date -d "@$epoch" +%H:%M:%S)" "${name##*/}"
    done
}

# Build id: 8 hex digits, random at startup and re-rolled every pass. Its
# only job is to change -- two screens with the same id are the same build.
# (A counter would grow into "pass 137" over a long session; this stays the
# same width and carries no meaning to misread.)
new_id() { printf '%08x' $(( RANDOM << 16 | RANDOM )); }
build_id=$(new_id)

run_pass() {
    local why=$1
    build_id=$(new_id)
    clear
    # The header is the proof a build ran: id, wall-clock time, what
    # triggered it, and the newest source mtime it built from.
    echo "### $build_id  $(date +%H:%M:%S)  $why  [newest source: $(newest_source)]"
    for t in "${TARGETS[@]}"; do
        IFS='|' read -r name mk cmd guard <<<"$t"
        name=${name// /}; mk=${mk// /}
        cmd=${cmd#"${cmd%%[![:space:]]*}"}; cmd=${cmd%"${cmd##*[![:space:]]}"}
        guard=${guard#"${guard%%[![:space:]]*}"}
        want "$name" && run_target "$name" "$mk" "$cmd" "$guard"
    done
    show_top
}

run_pass "startup"

# One long-lived inotifywait in monitor mode: events queue in the pipe while
# a pass runs, so a save that lands mid-build is never missed (the old
# "build, then start listening" loop was deaf for the whole build). Each
# event's path is read, then the queue is drained for a moment so a burst of
# saves collapses into one pass. close_write = a file finished being written.
inotifywait -m -q -r . @.git -e close_write -e move -e create \
    --exclude "$IGNORE" --format '%w%f' \
| while IFS= read -r changed; do
    while IFS= read -r -t 0.3 more; do changed=$more; done
    run_pass "${changed#./}"
done
