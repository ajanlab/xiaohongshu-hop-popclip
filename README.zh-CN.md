# 小红书 Hop

[English](./README.md) | 中文

选中任意文本 → 一键跳转小红书（网页版搜索 / 链接直达）。

## 功能

- **普通文本**（如 `AI 效率工具`）→ 小红书网页版搜索页
- **小红书链接**（`https://www.xiaohongshu.com/explore/xxx` 或 `xhslink.com/xxx`）→ 直接打开原文，跳过搜索
- **自动清洗**：去首尾空白与引号、折叠换行、URL 编码

## 安装

1. 从 [Releases 页面](https://github.com/ajanlab/xiaohongshu-hop-popclip/releases) 下载最新的 `xiaohongshu-hop.popclipextz`
2. 双击安装到 PopClip
3. 选中任意文本 → 点击 PopClip 工具栏的小红书图标

系统要求：macOS 10.15+，PopClip 2023+，python3（Xcode CLT 或 Homebrew）

### 从源码构建

```bash
cd xiaohongshu-hop.popclipext/
# 编辑 Config.yaml 或 Source/xiaohongshu-hop.sh
cd ..
zip -r xiaohongshu-hop.popclipextz xiaohongshu-hop.popclipext/
# 双击生成的 .popclipextz 安装
```

图标说明：`icon.png` 为 PopClip 模板图标，由官方 SVG（`assets/xhs-logo.svg`，圆角方块 + 内挖"小红书"文字的 iconfont 结构）经 Chrome headless 渲染 + 二值化生成，PopClip 自动适配工具栏深浅色模式。由 `assets/make_icon.py` 可复现（依赖 Google Chrome）：

```bash
python3 assets/make_icon.py 256   # 重新生成 xiaohongshu-hop.popclipext/icon.png
```

## 工作原理

```
选中文本 → 清洗(去引号/去空白) → 是否为小红书链接？
  ├─ 是 → 直接打开原文（跳过搜索）
  └─ 否 → URL 编码 → search_result?keyword=xxx
```

## 隐私

- **仅向小红书官方网页发送请求**，无第三方服务器、无统计、无追踪
- **无存储**：无缓存文件、无日志、无状态
- **零配置**：无需 API key、无需登录授权（搜索页本身可能需要登录，由小红书官方页面处理）
- **极简依赖**：bash、curl、open（macOS 内置）+ python3（Xcode CLT 或 Homebrew）

## 验证

命令行直接测试（无需 PopClip）：

```bash
# 1. 中文搜索
export POPCLIP_TEXT="AI 效率工具"
./xiaohongshu-hop.popclipext/Source/xiaohongshu-hop.sh
# 预期: 打开小红书搜索页

# 2. 完整链接直达
export POPCLIP_TEXT="https://www.xiaohongshu.com/explore/66a1b2c3"
./xiaohongshu-hop.popclipext/Source/xiaohongshu-hop.sh
# 预期: 直接打开该笔记页

# 3. 短链直达
export POPCLIP_TEXT="xhslink.com/AbC123"
./xiaohongshu-hop.popclipext/Source/xiaohongshu-hop.sh
# 预期: 补全 https:// 后打开

# 4. 空输入
export POPCLIP_TEXT=""
./xiaohongshu-hop.popclipext/Source/xiaohongshu-hop.sh
# 预期: exit 1，无浏览器动作

# 5. 自动化测试套件
chmod +x test.sh && ./test.sh
```

## 环境变量

| 变量 | 来源 | 说明 |
|---|---|---|
| `POPCLIP_TEXT` | PopClip | 选中的文本（必填） |

无需 API key，零配置。

## License

MIT License — 自由使用、修改与分发。
