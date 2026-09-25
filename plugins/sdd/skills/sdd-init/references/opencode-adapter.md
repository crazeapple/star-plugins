# OpenCode 适配设计（生成与验证的唯一规格源）

> 适配是初始化的自然组成部分（生成见 SKILL.md 第 2 节第 3 步，提交与验证见第 2 节第 4 步与「四、验证与回报」）；本文件仅承载逐字规格与设计依据。

## 核心原则

- **唯一源（OpenCode 侧零内容创造）**：治理规则唯一源 = `sdd/runtime/claude.md`（经 `opencode.json` 的 `instructions` 加载），OpenCode 侧新增内容仅 `sdd/runtime/opencode.md` 补充壳；命令唯一源 = `.claude/commands/*.md`，存根仅作引用壳。禁止复制正文（双源漂移）、禁止软链（跨平台克隆失效）、禁止在 OpenCode 侧另建平行规则或命令内容
- **AGENTS.md 为项目骨架**：公开面文件（项目名、定位、智能体协作声明），零 sdd 痕迹，两形态同文；不再是治理入口（治理规则经 `instructions` 直达）
- **本地化约定**：仅 `*.local.*` 后缀文件为机器本地；忽略机制按治理形态，inline 经 `.gitignore`、standalone 经 `.git/info/exclude`（排除清单由主会话按 SKILL.md standalone 分支写入）
- **零侵入**：治理文件（`sdd/`、`.claude/commands/`）零改动

## 生成文件逐字规格

`.gitignore`（仅 inline 形态；追加，不存在则新建，已含则跳过；standalone 形态一字不动）：

```
# 本地文件不入库
*.local.*
.worktree/
```

注意：`.opencode/opencode.json` inline 形态受 git 管理，禁止加入忽略清单；standalone 形态经排除清单忽略。

`AGENTS.md`（项目根，两形态同文；`<项目名>`、`<项目定位一句话>` 为 SKILL.md 第 2 节必填项）：

```
# <项目名> · OpenCode 入口

<项目定位一句话>

本项目由编程智能体（Claude Code / OpenCode）协助开发。
```

`.opencode/opencode.json`（两形态同文）：

```
{
  "$schema": "https://opencode.ai/config.json",
  "lsp": true,
  "instructions": ["../sdd/runtime/claude.md", "../sdd/runtime/opencode.md"]
}
```

`sdd/runtime/opencode.md`（OpenCode 补充壳，两形态同文）：

```markdown
# OpenCode 协作补充

本文件与 `runtime/claude.md` 经 `.opencode/opencode.json` 的 `instructions` 加载；命令以 `.opencode/commands/` 存根调用（`/sdd-intake` 等），存根 `@` 引用 `.claude/commands/` 同名命令文件。

## 外部文件加载

遇到 `@` 文件引用时，用读文件工具按需加载：按当前任务实际需要懒加载，禁止预先加载全部；加载后的内容视为强制指令，优先级高于默认行为；需要时递归跟随引用。
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
- 根 `AGENTS.md` 存在时 OpenCode 不再回退读 `CLAUDE.md`；2.0.0 起 AGENTS.md 为项目骨架，治理规则改经 `instructions` 加载 `sdd/runtime/` 两文件，不依赖 CLAUDE.md
- `instructions` 为 E2E 实证项：路径若相对配置目录解析则如上（`../sdd/…`），若相对项目根则去 `../` 前缀；接不上时回退 = 存根命令自带前置检查（读 CONSTITUTION → INDEX）保证流程可用，治理规则经命令文件内引用补达
- standalone 形态下贡献者 clone 无 `sdd/`，`instructions` 指向缺失文件须安全降级（不报错、不阻塞），属预期，E2E 核查
- 命令格式（frontmatter `description` + `$ARGUMENTS`）与 Claude Code 同构
- `"lsp": true` 按需启动全部内置 LSP 服务器，无源码零开销；首次运行自建 `.opencode/.gitignore`（自忽略）并后台安装 `@opencode-ai/plugin`，不出现在 `git status`，属预期

已否决、禁止执行时改道：`OPENCODE_CONFIG` 环境变量加载本地配置（换启动方式即失效）；共享根 `opencode.json`（配置统一收口 `.opencode/`）；AGENTS.md 纯提示词分发命令（无原生命令与补全，被存根方案取代）；迁移 `.claude/skills/` 双原生（需重构既有命令结构，超出适配范畴）；AGENTS.md 以 `@` 引用 CLAUDE.md 补回治理规则（2.0.0 起 CLAUDE.md 为项目骨架，无治理内容可补）。
