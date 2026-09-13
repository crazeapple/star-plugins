# 升级模式：既有 SDD 安装的就地合并（生成与验证的唯一规格源）

> 触发判定、对账分类、验证与回报以本文件为唯一规格源；设计决策见仓库 `docs/` 目录的 `DESIGN-SDD.md` §十六。升级复用初始化的四步骨架与全量验证，不新增命令。

## 一、触发判定

前置检查的冲突检测命中项构成**全套签名文件**时，经用户确认转升级模式；任一缺失则照旧停止并报告冲突清单——**部分存在不触发升级**，禁止自行补齐缺失项后覆盖。

签名集（以下存在性检查全部命中才转升级）：

- `sdd/CONSTITUTION.md`、`sdd/INDEX.md`、`sdd/INITIATIVE.md`、`sdd/amendments/amend.md`
- `sdd/templates/` 下 proposal / spec / design / task ×4 全在
- `sdd/tools/mdlint.sh`、`sdd/archive/README.md`
- `CLAUDE.md`、`.claude/commands/` 下 7 命令全在
- `AGENTS.md`、`.opencode/opencode.json`、`.opencode/commands/` 下 7 存根全在

`.gitignore` 与 `.git/hooks/pre-commit` 不入签名集（补装语义：缺失即补，存在即覆盖 / 补行）。典型场景为环境重建：项目于新主机 clone 后 `.git/hooks/pre-commit` 必然缺失，全套签名文件在库即命中本模式，重装即补。命中后向用户明示「检测到既有安装（版本见 `sdd/VERSION`），转入升级模式」并等待确认；确认后校验 git 索引干净（`git diff --cached --quiet`），有预置暂存则停止，请用户先处理（防混入升级提交）。

## 二、对账分类（三档）

| 档 | 文件 | 处置 |
|---|---|---|
| 静默覆盖 | `sdd/tools/mdlint.sh`、`.git/hooks/pre-commit`（重装并加可执行位）、`sdd/templates/` ×4、`.claude/commands/` ×7、`.opencode/opencode.json`、`.opencode/commands/` ×7 | 按规格纯复制覆盖 |
| 保护性写入 | `.gitignore`、`AGENTS.md`、`sdd/CONSTITUTION.md` | 规格重生成 + 项目内容回读回填（见下） |
| 活文档仲裁 | `CLAUDE.md` | 骨架节重写 + 项目内容保留（§六） |
| 禁触 | `sdd/INDEX.md`、`sdd/INITIATIVE.md`、`sdd/amendments/amend.md` 内容；`sdd/specs/`、`sdd/exploring/`、`sdd/journal.md`、`sdd/archive/` 全部 | 一律不改（骨架仅按 §八锚点只读比对） |

保护性写入细则：

- `.gitignore`：三行逐行补缺——`# 本地文件不入库`、`*.local.*`、`.worktree/`；已有行不动，项目自有行禁删禁改，文件不存在才新建；**严禁整文件重写**。
- `AGENTS.md`：按 `references/opencode-adapter.md` 逐字重生成，项目名回填（§三回读值）。
- `sdd/CONSTITUTION.md`：按 `references/constitution-design.md` 逐字重生成，项目名回填（§三回读值）；末尾生效日期保留原文件原值（识别原文件末尾 `YYYY-MM-DD` 日期行；回读失败以当日 `date +%F` 重置并在回报注明）。

## 三、必填项回读（升级模式不询问）

项目名 ← `CLAUDE.md` 首行标题（备选 `AGENTS.md` 标题）；项目定位一句话 ← `CLAUDE.md` 首段定位句；提交前校验命令 ← `CLAUDE.md`「路径、ID 与工程约定」节。三项均回读不到时询问用户（升级模式唯一询问点），拒答按默认值生成并在回报注明。

## 四、执行顺序与幂等

1. 起始时间戳（`date +%s`）→ 触发判定（§一）→ 必填项回读（§三）
2. 两路并行对账（§七）→ 主会话最后重写 `CLAUDE.md`（同初始化的串行屏障）→ 写 `sdd/VERSION`（内容 = `${CLAUDE_SKILL_DIR}/../../.claude-plugin/plugin.json` 的 `version` 原样）
3. 全量验证（复用 SKILL.md「四、验证与回报」全量项：mdLint 零 error + 交叉一致 + check-ignore + opencode debug config）→ 提交（§五）→ 回报（§五）

**幂等**：对账按「现行规格 vs 磁盘现状」状态化执行，不依赖版本值分支；升级可安全重跑，中断恢复 = 直接重跑（中断不会造成签名集缺损，重跑仍命中升级模式）。

## 五、提交与回报

- 提交按实际变更文件显式列举、禁用 `git add -A` 与 `git add .`，分两批（同初始化分主题）：第一批 = `CLAUDE.md` + 命令 ×7 + `sdd/CONSTITUTION.md` + `sdd/VERSION`，消息固定 `chore: 升级 SDD 治理体系（机械资产对账 + CLAUDE.md 活文档仲裁）`；第二批 = `AGENTS.md` + `.gitignore` + `.opencode/opencode.json` + `.opencode/commands/` ×7，消息固定 `chore: 升级 OpenCode 适配资产`。某批零变更 → 跳过并在回报注明（commit hash 为 0 / 1 / 2 个）。
- 回报项：模式与版本去向（`X → Y`，或「旧版安装 → Y」）+ 覆盖清单 + 仲裁结果（保留的项目字段与自有增补清单、被覆盖改动清单）+ 骨架差异报告（§八，无差异则注明）+ 跳过批次 + commit hash + mdLint 结论 + 各项验证结论 + 升级耗时（总时长，人类可读格式）+ pre-commit hook 重装结论。

## 六、CLAUDE.md 重写与回读规则

- 按节标题锚点识别骨架六节（标题与定位 / 需求层级 / 会话必读 / 命令一览 / 硬规则 / 路径、ID 与工程约定），以 `references/command-specs.md` CLAUDE.md 骨架规格重写。
- 命令一览表与硬规则属单源复制辖区：项目改写过也**以规格为准重写**，被覆盖改动逐项列入回报（用户可经 git 历史回退）。
- 项目填写三字段（项目名 / 定位一句话 / 提交前校验命令）回读保留（§三）；识别不到骨架锚点的小节视为项目自有内容，**原样保留**并在回报列出。

## 七、执行策略（两路并行）

- 组 U① 治理组：`CONSTITUTION.md` 重生成 + `INDEX.md` / `INITIATIVE.md` / `amendments/amend.md` 骨架锚点只读比对（§八）——自读本文件全文 + `references/constitution-design.md` 全文 + `references/command-specs.md` 生成骨架节。
- 组 U② 机械资产组：命令 ×7、模板 ×4、`mdlint.sh`、hook、OpenCode 适配 ×10 覆盖——自读本文件全文 + `references/opencode-adapter.md` 全文。
- 主会话自读本文件全文（CLAUDE.md 仲裁、验证与提交操盘——升级模式不适用「主会话无需预读」豁免）；不支持 subagents 时按 U① → U② → 主会话串行，步骤不变。

## 八、骨架差异比对与报告

只比锚点不比全文：INDEX——`next-P` / `next-T` 计数器标签在位 + 提案总览表表头列集合与现行规格一致；INITIATIVE——`next-I` 标签在位 + 条目格式引言行在位；`amendments/amend.md`——`next-A` 标签在位 + 条目格式指引行在位。计数器值、数据行、条目内容一律不参与比对（防活跃项目误报）。

报告格式固定：每文件一段 = 文件名 + 差异锚点清单 + 「人工迁移建议：对照 command-specs 对应骨架节」+ 明示「未自动修改」。

## 九、边界处置

- **部分安装**：照旧冲突停止并列缺失项（§一），禁止补齐后覆盖。
- **`sdd/VERSION` 缺失或损坏**（内容不匹配 `^[0-9]+\.[0-9]+\.[0-9]+$`）：照常升级（对账不依赖版本值），回报注明「旧版安装」或「版本标记异常，疑似损坏 / 篡改」。
- **opencode 未安装**：验证对应项跳过并在回报注明（同初始化条款，禁止自动安装）。
- **worktree 在途**：升级只写主干路径，与 worktree 内代码零交集；回报列 `ls .worktree/` 在途提案作提示；hook 重装落 `.git/hooks/`（共享 git dir），对全部 worktree 即时生效属预期。
- **并发改写**：不对 CLAUDE.md 加锁；提交前全量验证 + 幂等重跑兜底。
