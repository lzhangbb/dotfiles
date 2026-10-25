#!/usr/bin/env bash
# Claude Code status line
#   line 1: model | dir | git branch
#   line 2: context bar | cost
input=$(cat)

model=$(jq -r '.model.display_name // "?"' <<<"$input")
dir=$(jq -r '.workspace.current_dir // .cwd // ""' <<<"$input")
cost=$(jq -r '.cost.total_cost_usd // 0' <<<"$input")
pct=$(jq -r '(.context_window.used_percentage // 0) | floor' <<<"$input")

branch=$(git -C "$dir" symbolic-ref --short HEAD 2>/dev/null)
dirty=""
[ -n "$branch" ] && [ -n "$(git -C "$dir" status --porcelain 2>/dev/null | head -1)" ] && dirty="*"

# 10-cell context bar, colored by usage
filled=$((pct / 10)); [ "$filled" -gt 10 ] && filled=10
bar=""; for ((i = 0; i < 10; i++)); do if ((i < filled)); then bar+="█"; else bar+="░"; fi; done
if   [ "$pct" -ge 80 ]; then c=31
elif [ "$pct" -ge 50 ]; then c=33
else c=32; fi

printf '\033[36m %s\033[0m' "$model"
printf ' \033[2m|\033[0m \033[34m %s\033[0m' "${dir/#"$HOME"/\~}"
[ -n "$branch" ] && printf ' \033[2m|\033[0m \033[35m %s%s\033[0m' "$branch" "$dirty"
printf '\n'
printf '\033[%sm %s %s%%\033[0m' "$c" "$bar" "$pct"
printf ' \033[2m|\033[0m \033[33m $%.2f\033[0m\n' "$cost"
