# Xiaohongshu Hop

[中文](./README.zh-CN.md) | English

Select any text → instantly jump to Xiaohongshu (web search / direct link).

## Features

- **Plain text** (e.g. `AI 效率工具`) → Xiaohongshu web search page
- **Xiaohongshu link** (`https://www.xiaohongshu.com/explore/xxx` or `xhslink.com/xxx`) → open the note directly, skip search
- **Auto cleanup** — strips quotes, collapses newlines, URL-encodes the query

## Installation

1. Download the latest `xiaohongshu-hop.popclipextz` from the [Releases page](https://github.com/ajanlab/xiaohongshu-hop-popclip/releases)
2. Double-click to install into PopClip
3. Select any text → click the Xiaohongshu icon in PopClip's toolbar

System requirements: macOS 10.15+, PopClip 2023+, python3 (Xcode CLT or Homebrew)

### Build from Source

```bash
cd xiaohongshu-hop.popclipext/
# Edit Config.yaml or Source/xiaohongshu-hop.sh
cd ..
zip -r xiaohongshu-hop.popclipextz xiaohongshu-hop.popclipext/
# Double-click the resulting .popclipextz to install
```

Icon: `icon.png` is a PopClip template icon rendered from the official SVG (`assets/xhs-logo.svg`) via Chrome headless — see `assets/make_icon.py` (requires Google Chrome) to regenerate.

## How It Works

```
Selected text → clean (strip quotes/whitespace) → Xiaohongshu link?
  ├─ yes → open directly (skip search)
  └─ no → URL-encode → search_result?keyword=xxx
```

## Privacy

- **Only to Xiaohongshu's official web pages** — no third-party servers, no analytics, no tracking.
- **No storage** — no cache files, no logs, no state
- **Zero configuration** — no API keys, no login (the search page itself may require login; handled by Xiaohongshu's official page)
- **Minimal dependencies** — bash, curl, open (macOS built-in) + python3 (Xcode CLT or Homebrew)

## Verification

Test from the command line (no PopClip needed):

```bash
# 1. Plain text search
export POPCLIP_TEXT="AI 效率工具"
./xiaohongshu-hop.popclipext/Source/xiaohongshu-hop.sh
# Expected: opens Xiaohongshu search page

# 2. Full link direct jump
export POPCLIP_TEXT="https://www.xiaohongshu.com/explore/66a1b2c3"
./xiaohongshu-hop.popclipext/Source/xiaohongshu-hop.sh
# Expected: opens the note page directly

# 3. Short link direct jump
export POPCLIP_TEXT="xhslink.com/AbC123"
./xiaohongshu-hop.popclipext/Source/xiaohongshu-hop.sh
# Expected: prepends https:// and opens

# 4. Empty input
export POPCLIP_TEXT=""
./xiaohongshu-hop.popclipext/Source/xiaohongshu-hop.sh
# Expected: exit code 1, no browser action

# 5. Run automated test suite
chmod +x test.sh && ./test.sh
```

## Environment Variables

| Variable | Source | Description |
|---|---|---|
| `POPCLIP_TEXT` | PopClip | Selected text (required) |

No API keys required. Zero configuration.

## License

MIT License — free to use, modify, and distribute.
