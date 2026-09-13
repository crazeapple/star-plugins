---
name: sdd-init
description: Initialize the SDD requirements governance system (constitution / INDEX / INITIATIVE / commands / templates / mdlint) in the current project, including OpenCode adaptation. Use when the user asks to set up SDD governance in a new project, to upgrade an existing SDD installation to the current plugin version, or when REUSE-GUIDE step 1 requires governance initialization.
---

# 任务：在当前项目初始化 SDD 需求治理体系并适配 OpenCode

本技能为分发规格，设计决策以仓库 `docs/` 目录的 `DESIGN-SDD.md` 为准。**直接执行，禁止重新设计、增删决策。**

> **TL;DR**：① 前置检查（判定全新 / 升级模式）→ ② 问必填项（仅全新）→ ③ 全新：按 references 逐字生成 29 文件；升级：按 `references/upgrade.md` 就地合并 → ④ 全量验证后提交（全新两次，升级按实际变更）。
> **三条禁忌**：禁止擅自覆盖既有文件；禁止重新设计、增删决策；禁止跳过任何验证。

## 引用懒加载

正文只含主流程；规格位于 references，由生成阶段各组 subagent 自读、禁止预载全部：

- 并行生成（第 2 节第 3 步）：① 组读 `references/constitution-design.md`（治理体系核心设计——生成 CONSTITUTION.md 的逐字规格源）全文与 `references/command-specs.md`（命令、模板与语言规范，含生成骨架）；② 组读 command-specs 命令规格表与 constitution-design「状态转换 × 文档同步矩阵」节（定点读取）；④ 组读 `references/opencode-adapter.md`（OpenCode 适配设计）；③ 组纯复制无需读。主会话无需预读任何规格。
- 升级模式（第 2 节第 3 步升级分支）：组 U① / U② 与主会话均自读 `references/upgrade.md`（升级就地合并的逐字规格源）——U① 另读 constitution-design 全文与 command-specs 生成骨架节，U② 另读 opencode-adapter 全文；升级模式主会话不免预读（需操盘 CLAUDE.md 仲裁与提交验证）。

资产源（相对本技能目录，绝对路径前缀 `${CLAUDE_SKILL_DIR}/`）：

- 模板 ×4：`templates/proposal.md`、`templates/spec.md`、`templates/design.md`、`templates/task.md`（复制到目标项目 `sdd/templates/`）
- 治理工具：`scripts/mdlint.sh`（安装到目标项目 `sdd/tools/mdlint.sh`）
- 提交兜底 hook：`scripts/pre-commit.sh`（安装到目标项目 `.git/hooks/pre-commit` 并加可执行位；不入库、不占生成清单）

## 一、背景与目标

目标项目为 Vibe Coding 模式：AI 主导编码，需求对话式动态探索、粒度不一、高频变更；项目尾声或结束时，可归档干净完整的需求与设计文档供新项目复用，全部治理文档由 AI 按工作流自动维护。

本技能即可移植初始化器：任意项目会话中调用，即生成治理体系并交互完成初始化；自然包含 OpenCode 适配（逐字规格见 `references/opencode-adapter.md`），实现 Claude Code ⇄ OpenCode 无缝衔接开发。

运行前提：POSIX 环境（macOS/Linux，sh/awk/perl 可用——mdlint.sh 零依赖即指此）；非 POSIX 平台须先自备等价工具，否则禁止开工。

## 二、初始化流程（四步，顺序固定）

1. **前置检查**：
   - 记录起始时间戳（`date +%s`），收尾计算初始化耗时
   - 当前目录为项目根；非 git 仓库则自动执行 `git init`
   - 冲突检测：已存在 `sdd/`、`CLAUDE.md`、`.claude/commands/sdd-*.md`、`AGENTS.md`、`.opencode/` 或 `.git/hooks/pre-commit` 任一 → **停止并报告冲突清单**，由用户决定，禁止覆盖（标准处置二选一：跳过冲突项继续，或用户明示删除后重建；其余处置须用户逐项明示）；命中项构成全套签名文件（判定清单见 `references/upgrade.md` §一）时经用户确认转**升级模式**（就地合并，流程见该文件）——部分存在仍按本条停止，禁止补齐后覆盖
   - `opencode` 可用性：不可用则照常生成全部文件、最终回报中提示安装，禁止自动安装、不阻塞
2. **询问必填项**（升级模式跳过本步，改按 `references/upgrade.md` §三回读）：一次性向用户列出下表，等待回答；未回答项用默认值，必填项未获回答则再次询问、仍拒答则停止（启动日期不询问，`date +%F` 实取）：

   | 项 | 必填 | 默认值 / 说明 |
   |---|---|---|
   | 项目名 | 可默认 | 默认 = 当前目录名；用于 CLAUDE.md 与 AGENTS.md 标题 |
   | 项目定位一句话 | 必填 | CLAUDE.md 首行：一句话说明项目是什么、目的 |

3. **生成（全新模式，默认四路并行）**：按回答生成填好的 17 治理文件、1 治理工具 `sdd/tools/mdlint.sh` 与版本标记 `sdd/.version`（内容 = `${CLAUDE_SKILL_DIR}/../../.claude-plugin/plugin.json` 的 `version` 原样），用 subagents 按文件组分派并行，各组自读所需规格——① CONSTITUTION + INDEX + INITIATIVE + amendments/amend.md（读 `references/constitution-design.md` 全文 + `references/command-specs.md` 生成骨架）② 命令 ×7（读 command-specs 命令规格表 + constitution-design「状态转换 × 文档同步矩阵」节，定点读取）③ 模板 ×4 与 `tools/mdlint.sh`、`sdd/.version`、`.git/hooks/pre-commit`（纯复制自 `templates/`、`scripts/`，版本标记取插件清单 version 写入，hook 另加可执行位）+ archive 说明 ④ OpenCode 适配 ×10（读 `references/opencode-adapter.md`）；**CLAUDE.md 最后由主会话写**（引用全部生成物）。环境不支持 subagents 时按组序串行生成，步骤不变。升级模式不走本步生成流程，改按 `references/upgrade.md` §四就地合并（两路并行，CLAUDE.md 同样最后写）。
4. **收尾**：对全部生成文件（含适配文件）按下方「四、验证与回报」完成 mdLint 与各项验证（零 error）、两次独立 git 提交（19+10）、计算初始化耗时与回报。升级模式收尾按 `references/upgrade.md` §四-§五（复用全量验证，提交按实际变更分批）。

> **中断恢复**：会话中断后续跑时，已生成文件若与「四、验证与回报」清单吻合即视为本初始化产物，跳过前置检查的冲突判定；对照其清单补齐缺失文件、已验证项不重跑、必填项从已生成文件回读（项目名/定位见 CLAUDE.md），回读不到才询问；若存在清单外文件，照常停止报告冲突。升级模式中断 → 直接重跑升级（幂等，见 `references/upgrade.md` §四），恢复条款以该文件为准。

## 三、文档结构（17 治理文件 + 1 治理工具 + 1 版本标记 + 10 OpenCode 适配文件）

```
<项目根>/
├── CLAUDE.md                      # 会话入口：路标 + 硬规则摘要
├── AGENTS.md                      # OpenCode 入口：@ 引用 CLAUDE.md（单一事实源）
├── .gitignore                     # 本地文件不入库：*.local.*
├── .claude/commands/              # 7 命令，sdd- 前缀（命令唯一源）
│   ├── sdd-intake.md  sdd-finalize.md  sdd-split.md
│   ├── sdd-start.md  sdd-board.md  sdd-accept.md  sdd-archive.md
├── .opencode/
│   ├── opencode.json              # OpenCode 共享配置（lsp: true）
│   └── commands/                  # 7 命令存根（@ 引用 .claude/commands/ 同名文件）
└── sdd/
    ├── .version                   # 版本标记：初始化时插件清单 version（升级对账的回报基线，非治理文档）
    ├── CONSTITUTION.md            # SDD 治理宪法（根本法；不用 README.md，防执行者按默认习惯另建）
    ├── INDEX.md                   # 登记簿：Proposal 状态唯一权威 + P/T 发号计数器
    ├── INITIATIVE.md              # 意向池：意向唯一记录 + I 发号计数器
    ├── amendments/amend.md        # 修正登记簿 + A 发号计数器（决策反转追加式录入）
    ├── templates/  proposal.md  spec.md  design.md  task.md
    ├── tools/
    │   └── mdlint.sh              # 治理工具（非治理文档）：Markdown 规范校验
    └── archive/README.md          # 归档区说明（只读 + 四产物 + REUSE-GUIDE 用法）
```

运行态目录不预建（见 `references/constitution-design.md`「层级与分区」）。

另生成不入库的 `.git/hooks/pre-commit`（R8 提交兜底，契约见 `references/constitution-design.md`「校验」节；不入 29 文件清单）。

## 四、验证与回报

1. **失败处置（总则）**：任何验证失败，修复后必须重跑对应**全量**验证（mdLint 失败即对全部生成文件重跑，非仅复验出错项），全部通过方可进入下一步；禁止跳过任何验证步骤（明示豁免者除外）、禁止带病提交、禁止以「已修过」为由免检。
2. 29 文件齐全、结构正确、必填项已填（17 治理文件 + 1 治理工具 + 1 版本标记 + 10 OpenCode 适配文件）；`sdd/.version` 与插件清单 version 一致；`.git/hooks/pre-commit` 已生成且可执行（不入库、不占清单，初始化两次提交经其实测）；
3. 对全部生成文件运行 `sh sdd/tools/mdlint.sh sdd/ CLAUDE.md .claude/commands/ AGENTS.md .opencode/commands/`，零 error；
4. ID/状态机/矩阵在 CONSTITUTION、INDEX、INITIATIVE、模板、7 命令间交叉一致；
5. `git check-ignore -v .claude/settings.local.json .opencode/tmp.local.json`（后一文件名任取一个不存在的即可）→ 均命中；`git check-ignore .opencode/opencode.json` → 无输出（未被忽略）；
6. `opencode debug config` → 7 个 sdd 命令全部被发现（description 与 `references/command-specs.md` 命令规格表逐字一致、模板正确）且含 `"lsp": true`（opencode 未安装时跳过本条并在回报注明；其运行副产物被 `.opencode/.gitignore` 自忽略，不影响两次提交）；
7. git 提交共两次、各自独立，均显式列举文件路径添加、禁用 `git add -A` 与 `git add .`：第一次仅 19 清单文件，消息固定 `chore: 初始化 SDD 需求治理体系（17 治理文件 + mdlint 工具 + 版本标记）`；第二次仅 10 适配文件，消息固定 `chore: 适配 OpenCode（AGENTS.md 入口 + 命令存根 @ 引用 + .opencode 共享配置）`；除清单文件与 `.git/hooks/pre-commit`（不入库）外禁止创建任何其他文件（评审/提示词等用户文档不入库）；
8. 冒烟演练默认**不执行**，初始化完成后待命 `/sdd-intake` 接首个真实需求；后续冒烟（用户在 opencode TUI 手动）：输入 `/` 查看命令补全、执行任一只读命令（如 `/sdd-board`）、问「本项目会话必读是什么」应答 CONSTITUTION → INDEX → INITIATIVE（验证 `@CLAUDE.md` 链路）；
9. 最终回报：文件清单 + 两个 commit hash + mdLint 结论 + 各项验证结论 + 初始化耗时（总时长，人类可读格式）+ pre-commit hook 安装结论 + 模式（全新 / 升级）与版本去向（升级回报项见 `references/upgrade.md` §五）。
