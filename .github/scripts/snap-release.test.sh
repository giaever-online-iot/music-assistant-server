#!/usr/bin/env bash
# Fixture-driven unit tests for snap-release.sh. No network.
set -uo pipefail  # no -e: keep all tests running even if earlier ones fail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SR="$HERE/snap-release.sh"
INFO="$HERE/fixtures/snapcraft-status.txt"
fail=0

check() { # desc expected actual
  if [ "$2" = "$3" ]; then
    printf 'ok   - %s\n' "$1"
  else
    printf 'FAIL - %s\n       expected: [%s]\n       actual:   [%s]\n' "$1" "$2" "$3"
    fail=1
  fi
}

check "version-to-track bare"       "v2.9" "$("$SR" version-to-track 2.9.8)"
check "version-to-track v-prefixed" "v2.9" "$("$SR" version-to-track v2.9.8)"
check "version-to-track x.0"        "v3.0" "$("$SR" version-to-track 3.0.0)"
check "version-to-track empty"      ""     "$("$SR" version-to-track "")"

check "major bare"       "2" "$("$SR" major 2.9.8)"
check "major v-prefixed" "3" "$("$SR" major v3.0.0)"
check "major empty"      ""  "$("$SR" major "")"

check "channel-version candidate"  "2.9.7" "$("$SR" channel-version latest/candidate <"$INFO")"
check "channel-version stable"     "2.6.0" "$("$SR" channel-version latest/stable <"$INFO")"
check "channel-version inherited"  ""      "$("$SR" channel-version latest/beta <"$INFO")"
check "channel-version branch"     "2.9.8" "$("$SR" channel-version v2.9/edge/7 <"$INFO")"
check "channel-version old branch" "2.6.1" "$("$SR" channel-version v2.6/edge/9 <"$INFO")"
check "channel-version absent"     ""      "$("$SR" channel-version v9.9/stable <"$INFO")"

check "branch-has-revisions yes"   "yes" "$("$SR" branch-has-revisions v2.9 7 <"$INFO")"
check "branch-has-revisions no"    "no"  "$("$SR" branch-has-revisions v2.9 999 <"$INFO")"

# Same parser must also handle the interactive/TTY layout, where snapcraft blanks
# Track+Arch on continuation rows. CI captures non-interactively (repeated columns),
# but the parser is hardened for both — these lock that in.
TTY="$HERE/fixtures/snapcraft-status-tty.txt"
check "tty channel-version candidate" "2.9.7" "$("$SR" channel-version latest/candidate <"$TTY")"
check "tty channel-version branch"    "2.9.8" "$("$SR" channel-version v2.9/edge/7 <"$TTY")"
check "tty channel-version inherited" ""      "$("$SR" channel-version latest/beta <"$TTY")"
check "tty branch-has-revisions yes"  "yes"   "$("$SR" branch-has-revisions v2.9 7 <"$TTY")"

# stable-bump fires on a new v<major>.<minor> LINE (not only a new major).
check "needs-stable-bump minor line" "yes" "$("$SR" needs-stable-bump 2.10.0 2.9.8)"
check "needs-stable-bump major"      "yes" "$("$SR" needs-stable-bump 3.0.0 2.9.8)"
check "needs-stable-bump same line"  "no"  "$("$SR" needs-stable-bump 2.9.8 2.9.7)"
check "needs-stable-bump backport"   "no"  "$("$SR" needs-stable-bump 2.6.1 2.9.7)"
check "needs-stable-bump empty-cand" "no"  "$("$SR" needs-stable-bump 2.9.8 "")"
check "needs-stable-bump empty-new"  "no"  "$("$SR" needs-stable-bump "" 2.9.8)"

check "is-at-least equal"         "yes" "$("$SR" is-at-least 2.9.8 2.9.8)"
check "is-at-least greater"       "yes" "$("$SR" is-at-least 2.10.0 2.9.9)"
check "is-at-least lesser"        "no"  "$("$SR" is-at-least 2.6.1 2.9.7)"
check "is-at-least empty-floor"   "yes" "$("$SR" is-at-least 2.6.0 "")"
check "is-at-least minor-numeric" "yes" "$("$SR" is-at-least 2.10.0 2.9.0)"
check "is-at-least mixed-prefix"  "yes" "$("$SR" is-at-least v2.10 2.9)"

# latest-targets <new> <latest/candidate ver> <latest/edge ver> -> space-sep latest/* channels
# <new> may land on, each gated by <new> >= that channel's OWN version (no downgrades).
check "latest-targets both-newer"   "latest/candidate latest/edge" "$("$SR" latest-targets 2.9.8 2.9.7 2.9.7)"
check "latest-targets equal"        "latest/candidate latest/edge" "$("$SR" latest-targets 2.9.8 2.9.8 2.9.8)"
check "latest-targets edge-ahead"   "latest/candidate"             "$("$SR" latest-targets 2.9.7 2.9.7 2.9.8)"
check "latest-targets cand-ahead"   "latest/edge"                  "$("$SR" latest-targets 2.9.7 2.9.8 2.9.7)"
check "latest-targets backport"     ""                             "$("$SR" latest-targets 2.6.1 2.9.7 2.9.8)"
check "latest-targets empty-floors" "latest/candidate latest/edge" "$("$SR" latest-targets 2.9.8 "" "")"

exit "$fail"
