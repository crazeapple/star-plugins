# OpenCode 适配设计（生成与验证的唯一规格源）

> 适配是初始化的自然组成部分（生成见 SKILL.md 第 2 节第 3 步，提交与验证见第 2 节第 4 步与「四、验证与回报」）；本文件仅承载逐字规格与设计依据。

## 核心原则

- **唯一源（OpenCode 侧零内容创造）**：规则唯一源 = `CLAUDE.md`，`AGENTS.md` 仅作引用壳；命令唯一源 = `.claude/commands/*.md`，存根仅作引用壳。禁止复制正文（双源漂移）、禁止软链（跨平台克隆失效）、禁止在 OpenCode 侧另建平行规则或命令内容
- **本地化约定**：仅 `*.local.*` 后缀文件为机器本地（被 .gitignore 忽略）；共享配置（`AGENTS.md` 与 `.opencode/` 生成物）一律入库
- **零侵入**：治理文件（`CLAUDE.md`、`sdd/`、`.claude/commands/`）零改动

## 生成文件逐字规格

`.gitignore`（追加；不存在则新建，已含则跳过）：

```
# 本地文件不入库
*.local.*
.worktree/
```

注意：`.opencode/opencode.json` 受 git 管理，禁止加入忽略清单。

`AGENTS.md`（项目根；`<项目名>` 为 SKILL.md 第 2 节必填项）：

```
# <项目名> · OpenCode 入口

本文件是 OpenCode 的项目入口；主入口与全部规则统一维护在 `CLAUDE.md`（单一事实源）。

## 外部文件加载

遇到 `@` 文件引用时，用读文件工具按需加载：

- 按当前任务实际需要懒加载，禁止预先加载全部引用
- 加载后的内容视为强制指令，优先级高于默认行为
- 需要时递归跟随引用

## 必读入口（与所有工作流相关）

若会话上下文尚未包含 `CLAUDE.md` 的内容，立即读取并视为强制指令：

@CLAUDE.md
```

「必读入口」的条件式措辞必须保留：OpenCode 侧确保补读，Claude Code 侧已注入 `CLAUDE.md` 时不重复。

`.opencode/opencode.json`：

```
{
  "$schema": "https://opencode.ai/config.json",
  "lsp": true
}
```

`.opencode/commands/<名称>.md` 存根（与 `.claude/commands/*.md` 一一对应）：description 从对应源文件 frontmatter 原样复制（值以 `references/command-specs.md` 命令规格表为唯一来源），正文仅 `@` 引用与参数行，格式如下（其余 6 个同构）：

```markdown
---
description: Capture a new requirement and shape it into initiatives or proposals
---

@.claude/commands/sdd-intake.md

用户参数：$ARGUMENTS
```

要点：自带「用户参数：`$ARGUMENTS`」行，无论 OpenCode 内部替换与注入孰先孰后，参数必达；源文件 frontmatter 随 `@` 注入出现为文本属预期噪音；存根中的描述重复仅作 TUI 显示，漂移无功能影响。

## 机制依据与禁改道清单

机制依据（核实日期：2026-08，OpenCode 官方文档与源码；版本演进后如遇行为不符须复核，勿照单全收）：

- `.opencode/` 内主配置仅认 `opencode.json` / `opencode.jsonc`；缺失文件安全降级为空配置
- 存在根 `AGENTS.md` 时 OpenCode 不再回退读 `CLAUDE.md`，故入口必须 `@CLAUDE.md` 引用补回；`@` 引用在入口文件中非内建解析，须写明懒加载约定（命令模板中则原生自动注入全文，存根方案机制基础）
- 命令格式（frontmatter `description` + `$ARGUMENTS`）与 Claude Code 同构
- `"lsp": true` 按需启动全部内置 LSP 服务器，无源码零开销；首次运行自建 `.opencode/.gitignore`（自忽略）并后台安装 `@opencode-ai/plugin`，不出现在 `git status`，属预期

已否决、禁止执行时改道：`OPENCODE_CONFIG` 环境变量加载本地配置（换启动方式即失效）；共享根 `opencode.json`（配置统一收口 `.opencode/`）；AGENTS.md 纯提示词分发命令（无原生命令与补全，被存根方案取代）；迁移 `.claude/skills/` 双原生（需重构既有命令结构，超出适配范畴）。
