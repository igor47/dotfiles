#!/usr/bin/env bash
# Block until the tmux pane shows a confirmation prompt, then print the pane's
# tail and exit. With --after-clear, first wait for the prompt on screen now to
# go away or be replaced by a different one, so the one just answered is not
# reported again. Back-to-back prompts often replace each other with no gap a
# poll can see, so "no prompt on screen" alone is not a safe signal.
#
#   watch.sh <target> [--after-clear] [--lines N]
#
# <target> is a tmux target such as 0:0.4 (session:window.pane).

set -u

target=${1:?usage: watch.sh <target> [--after-clear] [--lines N]}
shift
after_clear=0
lines=60
while [ $# -gt 0 ]; do
  case $1 in
    --after-clear) after_clear=1 ;;
    --lines) lines=$2; shift ;;
    *) echo "unknown flag: $1" >&2; exit 2 ;;
  esac
  shift
done

prompt_re='Do you want to proceed|\(yes/no|\[y/n\]|\[Y/n\]|passphrase|[Pp]assword:'

capture() { tmux capture-pane -p -t "$target" 2>/dev/null | tail -"$lines"; }
has_prompt() { /usr/bin/grep -qE "$prompt_re"; }
# Identify a prompt by its box: the lines between the box's top rule (a line of
# ─) and its question. Lines above the rule are transcript, where the blinking
# ⏺ bullet and the spinner change from one poll to the next, so they must stay
# out. Without a rule (not a Claude Code prompt), fall back to the last 15 lines.
# Glyphs that animate or follow the cursor are stripped either way.
fingerprint() {
  sed '/Do you want to proceed/,$d' |
    awk '/^──────────/ { box = ""; ruled = 1; next } { box = box $0 "\n"; all = all $0 "\n" }
         END { if (ruled) printf "%s", box; else printf "%s", all }' |
    tail -15 | sed 's/[❯⏺✻✶✢✳·]//g' | cksum
}

if ! tmux capture-pane -p -t "$target" >/dev/null 2>&1; then
  echo "cannot read tmux pane $target" >&2
  exit 1
fi

if [ "$after_clear" = 1 ]; then
  out=$(capture)
  if echo "$out" | has_prompt; then
    seen=$(echo "$out" | fingerprint)
    while true; do
      sleep 2
      out=$(capture)
      echo "$out" | has_prompt || break
      if [ "$(echo "$out" | fingerprint)" != "$seen" ]; then
        echo "PROMPT DETECTED in $target"
        echo "$out"
        exit 0
      fi
    done
    sleep 2
  fi
fi

while true; do
  out=$(capture)
  if [ -z "$out" ] && ! tmux has-session -t "${target%%:*}" 2>/dev/null; then
    echo "PANE GONE: $target"
    exit 0
  fi
  if echo "$out" | has_prompt; then
    echo "PROMPT DETECTED in $target"
    echo "$out"
    exit 0
  fi
  sleep 2
done
