# claude-code-statusline

A [Claude Code](https://docs.claude.com/en/docs/claude-code) status line that shows three orange progress bars:

- **ctx** — context window usage, with a `│` marker at the 200k-token auto-compact threshold
- **5h** — 5-hour rate limit usage
- **wk** — 7-day rate limit usage

Each bar is followed by a percentage, with white `|` separators between them.

```
ctx ████┼██░░░░░░░░░░░░░  35% | 5h ████░░░░░░░░░░░░░░░░  22% | wk █░░░░░░░░░░░░░░░░░░░   8%
```

## Install

1. Copy the script somewhere, e.g. `~/.claude/statusline.sh`:

   ```bash
   curl -o ~/.claude/statusline.sh https://raw.githubusercontent.com/Isolyth/claude-code-statusline/main/statusline.sh
   chmod +x ~/.claude/statusline.sh
   ```

2. Add a `statusLine` block to `~/.claude/settings.json`:

   ```json
   {
     "statusLine": {
       "type": "command",
       "command": "bash /Users/YOU/.claude/statusline.sh"
     }
   }
   ```

3. Restart Claude Code (or start a new session).

## Requirements

- `bash`, `jq`, `awk` — standard on macOS and most Linux distros
- A terminal that supports ANSI 256-color escapes

## Notes

- The `5h` and `wk` bars only populate for Claude.ai subscribers after the first API call in a session. On raw API-key usage they show `--`.
- The 200k marker is placed on the context bar proportionally to the session's actual context window size (1M for Opus 4.7, 200k for older models — in which case the marker sits at the end of the bar).
