#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input"   | jq -r '.workspace.current_dir')
COST=$(echo "$input"  | jq -r '.cost.total_cost_usd // 0')
PCT=$(echo "$input"   | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
USED_TOK=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
WIN_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
EFFORT=$(echo "$input" | jq -r '.effort.level // empty')
THINKING=$(echo "$input" | jq -r '.thinking.enabled // false')
FAST=$(echo "$input" | jq -r '.fast_mode // false')
RATE5=$(echo "$input"  | jq -r '.rate_limits.five_hour.used_percentage // 0 | round')
RATE7=$(echo "$input"  | jq -r '.rate_limits.seven_day.used_percentage // 0 | round')
LINES_ADD=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
LINES_DEL=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')
SESSION=$(echo "$input" | jq -r '.session_name // empty')

CYAN='\033[36m'; GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'
GRAY='\033[38;5;245m'; DIM='\033[38;5;240m'; RESET='\033[0m'

# Context bar color
if   [ "$PCT" -ge 90 ]; then BAR_COLOR="$RED"
elif [ "$PCT" -ge 70 ]; then BAR_COLOR="$YELLOW"
else BAR_COLOR="$GREEN"; fi

FILLED=$((PCT / 10)); EMPTY=$((10 - FILLED))
printf -v FILL "%${FILLED}s"; printf -v PAD "%${EMPTY}s"
BAR="${FILL// /█}${PAD// /░}"

# Session-scoped timer + cost — keyed by session_name
SESSION_KEY="${SESSION:-default}"
SESSION_KEY_SAFE=$(printf '%s' "$SESSION_KEY" | tr -cs 'a-zA-Z0-9_-' '_')
SESSION_STATE_FILE="/tmp/claude-session-${SESSION_KEY_SAFE}.state"
if [ ! -f "$SESSION_STATE_FILE" ]; then
  printf '%s %s %s %s\n' "$(date +%s)" "$COST" "$LINES_ADD" "$LINES_DEL" > "$SESSION_STATE_FILE"
fi
read -r START COST_BASE LINES_ADD_BASE LINES_DEL_BASE < "$SESSION_STATE_FILE"
NOW=$(date +%s)
TOTAL_S=$((NOW - START))
if   [ "$TOTAL_S" -lt 60 ]; then
  TIMER="${TOTAL_S}s"
elif [ "$TOTAL_S" -lt 3600 ]; then
  TIMER="$((TOTAL_S / 60))m $((TOTAL_S % 60))s"
else
  TIMER="$((TOTAL_S / 3600))h $(((TOTAL_S % 3600) / 60))m"
fi

# Token count: human-readable (e.g. 37.9k/200k)
fmt_k() {
  local n=$1
  if [ "$n" -ge 1000 ]; then
    printf "%.1fk" "$(echo "scale=1; $n/1000" | bc)"
  else
    printf "%d" "$n"
  fi
}
USED_FMT=$(fmt_k "$USED_TOK")
WIN_FMT=$(fmt_k "$WIN_SIZE")

# Git branch
BRANCH=""
git rev-parse --git-dir > /dev/null 2>&1 && BRANCH=" ${DIM}|${RESET} 🌿 $(git branch --show-current 2>/dev/null)"

# Badges
BADGES=""
[ "$THINKING" = "true" ] && BADGES="${BADGES} 🧠"
[ "$FAST"     = "true" ] && BADGES="${BADGES} ⚡"
[ -n "$EFFORT" ]         && BADGES="${BADGES} ${DIM}[${EFFORT}]${RESET}"

# Rate limits — color by severity
rate_color() {
  local p=$1
  if   [ "$p" -ge 90 ]; then printf '%s' "$RED"
  elif [ "$p" -ge 70 ]; then printf '%s' "$YELLOW"
  else printf '%s' "$GRAY"; fi
}
R5C=$(rate_color "$RATE5"); R7C=$(rate_color "$RATE7")
RATE_PART=" ${DIM}|${RESET} ${R5C}5h:${RATE5}%${RESET} ${R7C}7d:${RATE7}%${RESET}"

# Recommendation: summarize + /clear
HINT=""
if [ "$PCT" -ge 80 ] || [ "$RATE5" -ge 70 ]; then
  HINT=" ${RED}→ sum+/clear${RESET}"     # critical: now
elif [ "$PCT" -ge 50 ] || [ "$RATE5" -ge 40 ]; then
  HINT=" ${YELLOW}→ sum+/clear${RESET}"  # warning: soon
fi

# Session name (truncate at 30 chars)
SESSION_PART=""
if [ -n "$SESSION" ]; then
  SHORT_SESSION="${SESSION:0:30}"
  [ "${#SESSION}" -gt 30 ] && SHORT_SESSION="${SHORT_SESSION}…"
  SESSION_PART=" ${DIM}\"${SHORT_SESSION}\"${RESET}"
fi

# Lines changed (session delta)
SESSION_ADD=$((LINES_ADD - LINES_ADD_BASE))
SESSION_DEL=$((LINES_DEL - LINES_DEL_BASE))
DIFF_PART=""
if [ "$SESSION_ADD" -gt 0 ] || [ "$SESSION_DEL" -gt 0 ]; then
  DIFF_PART=" ${GREEN}+${SESSION_ADD}${RESET}/${RED}-${SESSION_DEL}${RESET}"
fi

SESSION_COST=$(echo "scale=4; $COST - $COST_BASE" | bc)
COST_FMT=$(printf '$%.4f' "$SESSION_COST")

echo -e "${CYAN}[${MODEL}]${RESET}${BADGES} 📁 ${DIR##*/}${BRANCH}${SESSION_PART}${HINT}"
echo -e "${BAR_COLOR}${BAR}${RESET} ${PCT}% ${DIM}(${USED_FMT}/${WIN_FMT})${RESET} | ${YELLOW}${COST_FMT}${RESET}${DIFF_PART} | ⏱️ ${TIMER}${RATE_PART}"
