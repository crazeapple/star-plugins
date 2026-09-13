# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 仓库定位

本仓是 Claude Code 插件 monorepo **分发仓**（marketplace `star-plugins`，当前唯一插件 `sdd`），同时是 SDD 体系的**唯一发展与规格权威**：无构建系统、无测试框架——内容为 Markdown 规格与 POSIX shell 脚本。

- **设计总纲**：仓库 `docs/` 目录的 `DESIGN-SDD.md`——SDD 需求流程的设计权威；一切规格演进先修订它，再落插件规格。
- **可移植提示词**：仓库 `docs/` 目录的 `PROMPT-SDD.md`——单文件版初始化提示词，由 `DESIGN-SDD.md` 与插件规格提炼而来，改设计时须同步。
- **插件内容**：skill `sdd-init`（可移植初始化器：在任意目标项目生成整套 SDD 治理体系、适配 OpenCode 并安装 `.git/hooks/pre-commit` 提交兜底——唯一机械强制 hook）。
- **插件刻意不含工作流命令**：命令由 sdd-init 生成于目标项目 `.claude/commands/`（OpenCode 存根依赖项目内文件）。不要把命令搬进插件。
- **规格实现**：插件规格（SKILL.md / references ×4 / templates ×4）与 `DESIGN-SDD.md` 一致。

## 常用操作

```sh
# 用本仓的 mdLint 校验任意 Markdown（治理文档零 error 方可回报完成）
sh plugins/sdd/skills/sdd-init/scripts/mdlint.sh <文件或目录>
```

- 修改 `mdlint.sh` 后必须过 4 条自测向量（见 `references/constitution-design.md`「校验」节）：行内反引号单只不闭合 → error；中英文粘连 → warning；同情形位于代码围栏/行内代码内 → 豁免；「模板 ×4」→ 无输出。
- 端到端试装：`/plugin marketplace add <本仓路径>` → `/plugin install sdd@star-plugins` → 在临时目标项目根运行 `/sdd:sdd-init` 验证生成流程。
- 端到端试升级：同上装好插件后，在已初始化的临时项目重跑 `/sdd:sdd-init` 验证升级模式（机械资产更新、运行态未动、`sdd/.version` 更新）；细则见 `plugins/sdd/skills/sdd-init/references/upgrade.md`。
- 试 pre-commit：临时仓库置 `sdd/tools/mdlint.sh` 并装入 `.git/hooks/pre-commit`（源 `plugins/sdd/skills/sdd-init/scripts/`），过 constitution-design「校验」节的自测向量。

## 编辑纪律

- **设计变更先修订 `DESIGN-SDD.md`**，再落插件规格；references 是逐字规格、templates 骨架即规格，禁止顺手改。
- **单源复制**：命令的英文 `description` 与 `$ARGUMENTS` 约定以 `references/command-specs.md` 命令规格表为唯一来源；生成命令 frontmatter、CLAUDE.md 命令表、OpenCode 存根描述时一律照抄，禁止另编。
- **语言**：规格/治理文档正文中文；命令 frontmatter `description` 英文；文件名英文 kebab-case（冷启动必读文档大写）。
- **Markdown 风格受治理规范约束**（中文全角标点、中英文间半角空格、强调用 `*` 禁 `_`、破折号「——」等，mdlint 机械检查），本仓文档同样按此书写。

## 架构要点

- **两层分发结构**：`.claude-plugin/marketplace.json`（marketplace 清单）→ `plugins/sdd/.claude-plugin/plugin.json`（插件清单）→ skill + hook。
- **skill 懒加载**：`SKILL.md` 只含主流程；规格在 `references/`，按步骤按需读取，禁止预载全部。资产以 `${CLAUDE_SKILL_DIR}/` 定位，复制（非引用）进目标项目。
- **提交兜底链路**：sdd-init 复制 `skills/sdd-init/scripts/pre-commit.sh` 为目标项目 `.git/hooks/pre-commit`（不入库、不占清单）；staged 辖区 `.md` 有 error 非零退出阻止提交，为唯一机械强制 hook；自测向量见 `references/constitution-design.md`「校验」节。
- **mdlint 契约**：error = 行内反引号/`**` 不配对、全角圆括号/直角引号文件级不配对；warning = 中英文粘连、无序列表标记非 `-`、表格列数与表头不一致；豁免代码围栏与行内代码；有 error 单文件退出 1、汇总退出 1。零依赖（POSIX sh + perl）。
- **sdd-init 运行时不变量**：生成 29 文件（17 治理 + 1 工具 + 1 版本标记 `sdd/.version` + 10 适配）+ 不入库的 `.git/hooks/pre-commit`（提交兜底）；验证零 error；两次独立 git 提交（19 + 10 文件，消息固定，显式列举路径，禁 `git add -A`/`git add .`）；全套签名文件齐全转升级模式（就地合并，见 DESIGN-SDD.md §十六）、部分存在才冲突即停、禁止覆盖既有文件；卸载插件对已初始化项目零影响。
