#!/bin/bash
# Xiaohongshu Hop — selected text → Xiaohongshu search / direct link
# 1. Xiaohongshu link (xiaohongshu.com / xhslink.com) → open directly
# 2. Anything else → Xiaohongshu web search (search_result?keyword=)
# Design: smart detection + graceful degradation. Xiaohongshu has no public
# search API, so link detection replaces the "unique match jump"; search is
# the fallback path.

set -euo pipefail

# Python 3 — macOS does not ship python3 by default.
# Requires Xcode Command Line Tools (xcode-select --install) or Homebrew.
# If unavailable, degrade to raw search: no cleanup, no encoding, no link detection.
PYTHON=""
command -v python3 >/dev/null 2>&1 && PYTHON="python3"
[ -z "$PYTHON" ] && [ -x /usr/bin/python3 ] && PYTHON="/usr/bin/python3"

raw_text=$(printf '%s\n' "${POPCLIP_TEXT:-}")

if [ -z "$PYTHON" ]; then
    [ -z "$raw_text" ] && exit 1
    # nohup: PopClip sends SIGHUP to child processes; without it the browser never opens
    nohup /usr/bin/open "https://www.xiaohongshu.com/search_result?keyword=$raw_text" >/dev/null 2>&1 &
    exit 0
fi

# Step 1: clean — strip quotes/whitespace, collapse newlines to a single line
clean_text=$(printf '%s\n' "$raw_text" | "$PYTHON" -c "
import sys
text = sys.stdin.read().strip().strip('\"').strip(\"'\")
print(' '.join(text.split()))
")
[ -z "$clean_text" ] && exit 1

# Step 2: decide + produce — link → prepend scheme & open; otherwise URL-encode & search
# Output is "URL <url>" or "SEARCH <encoded>": neither segment contains
# spaces (URLs pass fullmatch, queries are percent-encoded), so splitting on
# the first space is safe.
result=$(printf '%s\n' "$clean_text" | "$PYTHON" -c "
import re, sys, urllib.parse
text = sys.stdin.read().strip()
if re.fullmatch(r'(https?://)?(([a-z0-9-]+\.)*xiaohongshu\.com|xhslink\.com)(/[^\s]*)?', text, re.IGNORECASE):
    url = text if text.startswith(('http://', 'https://')) else 'https://' + text
    print('URL ' + url)
else:
    print('SEARCH ' + urllib.parse.quote(text, safe=''))
")

kind=${result%% *}
payload=${result#* }

if [ "$kind" = "URL" ]; then
    nohup /usr/bin/open "$payload" >/dev/null 2>&1 &
else
    nohup /usr/bin/open "https://www.xiaohongshu.com/search_result?keyword=$payload" >/dev/null 2>&1 &
fi
