#!/usr/bin/env bash
# Claude Code status line: three progress bars (ctx, 5h rate limit, weekly rate limit)

input=$(cat)

# ANSI 256-color orange (color 208), white, reset
ORANGE="\033[38;5;208m"
WHITE="\033[37m"
RESET="\033[0m"
SEP="${WHITE} | ${RESET}"

# Progress bar width in characters
BAR_WIDTH=20

# Build a progress bar string.
# Usage: make_bar <pct_float> [marker_pct_float]
# Fills with █ for filled portion, ░ for empty.
# If marker_pct is given, places a │ character at that fractional position.
make_bar() {
  local pct="$1"
  local marker_pct="${2:-}"
  local filled empty marker_pos i bar=""

  filled=$(awk "BEGIN { v = int($pct / 100 * $BAR_WIDTH); if (v > $BAR_WIDTH) v = $BAR_WIDTH; if (v < 0) v = 0; print v }")
  empty=$(( BAR_WIDTH - filled ))

  if [ -n "$marker_pct" ]; then
    marker_pos=$(awk "BEGIN { print int($marker_pct / 100 * $BAR_WIDTH) }")
  else
    marker_pos=-1
  fi

  for (( i=0; i<BAR_WIDTH; i++ )); do
    if [ "$i" -eq "$marker_pos" ] && [ "$i" -ge "$filled" ]; then
      # Marker is in the unfilled region: show as distinct char
      bar+="│"
    elif [ "$i" -eq "$marker_pos" ] && [ "$i" -lt "$filled" ]; then
      # Marker is inside the filled region: show as distinct char
      bar+="┼"
    elif [ "$i" -lt "$filled" ]; then
      bar+="█"
    else
      bar+="░"
    fi
  done

  printf "%s" "$bar"
}

# --- Context window bar ---
ctx_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')

if [ -n "$ctx_pct" ] && [ -n "$ctx_size" ]; then
  ctx_pct_int=$(printf "%.0f" "$ctx_pct")
  # Marker at 200k tokens expressed as a percentage of the full window size
  marker_pct=$(awk "BEGIN { printf \"%.4f\", 200000 / $ctx_size * 100 }")
  ctx_bar=$(make_bar "$ctx_pct" "$marker_pct")
  printf "${ORANGE}ctx ${ctx_bar} %3d%%${RESET}" "$ctx_pct_int"
else
  printf "ctx [%-${BAR_WIDTH}s]  --" ""
fi

# --- 5-hour rate limit bar ---
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')

printf "${SEP}"
if [ -n "$five_pct" ]; then
  five_pct_int=$(printf "%.0f" "$five_pct")
  five_bar=$(make_bar "$five_pct")
  printf "${ORANGE}5h ${five_bar} %3d%%${RESET}" "$five_pct_int"
else
  printf "5h [%-${BAR_WIDTH}s]  --" ""
fi

# --- 7-day (weekly) rate limit bar ---
week_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

printf "${SEP}"
if [ -n "$week_pct" ]; then
  week_pct_int=$(printf "%.0f" "$week_pct")
  week_bar=$(make_bar "$week_pct")
  printf "${ORANGE}wk ${week_bar} %3d%%${RESET}" "$week_pct_int"
else
  printf "wk [%-${BAR_WIDTH}s]  --" ""
fi
