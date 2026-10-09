---
name: sdd-init
description: Initialize the SDD requirements governance system (constitution / INDEX / commands / templates / mdlint) in the current project, choosing an inline or standalone governance layout, including OpenCode adaptation. Use when the user asks to set up SDD governance in a new project, to refresh or upgrade an existing SDD installation.
---

# 任务：在当前项目初始化 SDD 需求治理体系并适配 OpenCode

本技能为分发规格，设计决策以仓库 `docs/` 目录的 `DESIGN-SDD.md` 为准。**直接执行，禁止重新设计、增删决策。**

> **TL;DR**：① 前置检查（dispatch：全新 / 既有命中 / 冲突即停；形态按 `sdd/.git` 判定，既有低版本安装一律视为 inline）→ ② 询问（仅全新；全项默认兜底，治理形态默认 standalone 且 init 后不可切换、版本格式默认 SemVer、验收模式默认 auto）→ ③ 生成 30 文件（standalone 同数 30）；既有安装按 `references/upgrade.md` 就地合并（撤档与两支线）→ ④ 全量验证后提交（inline 全新两次；standalone 两仓各一笔；校准按实际变更）。
> **三条禁忌**：禁止擅自覆盖既有文件；禁止重新设计、增删决策；禁止跳过任何验证。

## 引用懒加载

正文只含主流程；规格位于 references，由生成阶段各组 subagent 自读、禁止预载全部：

- 并行生成（第 2 节第 3 步）：① 组读 `references/constitution-design.md`（治理体系核心设计：生成 `CONSTITUTION.md` 的逐字规格源）全文与 `references/command-specs.md`（命令、模板与语言规范，含生成骨架）；② 组读 command-specs 命令规格表与 constitution-design「状态转换 × 文档同步矩阵」节（定点读取）；④ 组读 `references/opencode-adapter.md`（OpenCode 适配设计）；③ 组纯复制无需读。主会话无需预读任何规格。
- 升级模式（第 2 节第 3 步升级分支）：组 U① / U② 与主会话均自读 `references/upgrade.md`（升级就地合并的逐字规格源），U① 另读 constitution-design 全文与 command-specs 生成骨架节，U② 另读 opencode-adapter 全文；升级模式主会话不免预读（需操盘 `CLAUDE.md` 仲裁与提交验证）。

资产源（相对本技能目录，绝对路径前缀 `${CLAUDE_SKILL_DIR}/`）：

- 模板 ×4：`templates/proposal.md`、`templates/spec.md`、`templates/design.md`、`templates/task.md`（复制到目标项目 `sdd/templates/`）
- 治理工具：`scripts/mdlint.sh`（安装到目标项目 `sdd/tools/mdlint.sh`）
- 提交门禁 hook：`scripts/pre-commit.sh`（写入目标项目 `.githooks/pre-commit`，入库占生成清单；含内嵌 mdlint 段与工具链路由段骨架）
- 内层提交兜底 hook：`scripts/pre-commit-inner.sh`（standalone 形态安装到 `sdd/.git/hooks/pre-commit` 并加可执行位；不入库、不占生成清单）

## 一、背景与目标

目标项目为 Vibe Coding 模式：AI 主导编码，需求对话式动态探索、粒度不一、高频变更；全部治理文档由 AI 按工作流自动维护。

本技能即可移植初始化器：任意项目会话中调用，即生成治理体系并交互完成初始化；自然包含 OpenCode 适配（逐字规格见 `references/opencode-adapter.md`），实现 Claude Code ⇄ OpenCode 无缝衔接开发。

运行前提：POSIX 环境（macOS/Linux，sh/awk/perl 可用，`mdlint.sh` 零依赖即指此）；非 POSIX 平台须先自备等价工具，否则禁止开工。

## 二、初始化流程（四步，顺序固定）

1. **前置检查**：
   - 记录起始时间戳（`date +%s`），收尾计算初始化耗时
   - 当前目录为项目根；非 git 仓库则自动执行 `git init`
   - 冲突检测与 dispatch：已存在 `sdd/`、`CLAUDE.md`、`CLAUDE.local.md`、`.claude/commands/sdd-*.md`、`AGENTS.md`、`.opencode/`、`.git/hooks/pre-commit`、`.githooks/` 或 `.husky/` 任一（`git config core.hooksPath` 已设亦同） → **停止并报告冲突清单**，由用户决定，禁止覆盖（标准处置二选一：跳过冲突项继续，或用户明示删除后重建；其余处置须用户逐项明示）。命中项构成签名集（判定清单见 `references/upgrade.md` §一）时转升级模式就地合并（撤档与两支线细则见该文件），并判定治理形态（`sdd/` 为独立 git 仓即 standalone；旧版安装一律视为 inline），部分存在且无标记仍按本条停止，禁止补齐后覆盖
   - `opencode` 可用性：不可用则照常生成全部文件、最终回报中提示安装，禁止自动安装、不阻塞
2. **询问**（既有安装跳过本步，改按 `references/upgrade.md` §三回读）：一次性向用户列出下表，等待回答；**全部询问项均有默认值兜底，未回答项直接取默认，无硬阻塞停止点**（启动日期不询问，`date +%F` 实取）：

   | 项 | 默认值 / 说明 |
   |---|---|
   | 项目名 | 默认 = 当前目录名；用于 `CLAUDE.md` 与 `AGENTS.md` 标题 |
   | 项目定位一句话 | `CLAUDE.md` 首行：依项目名 / 目录名与现场线索（README、`package.json` 等）生成 1-3 条候选并标注默认；未答取默认 |
   | 治理形态 | 默认 standalone。选项行固定：`inline 仓（内联，随项目仓）/ standalone 仓（独立，单独治理仓，默认；init 后不可切换，项目需对外无痕或治理不入项目仓时选此）`；参考判据见 `DESIGN-SDD.md` §十八八面表；形态 init 后不可切换 |
   | 版本格式 | 默认 SemVer。CalVer（`YYYY.M.D` 验收日，同日多发如 `2026.10.9.2`）或 SemVer（`vX.Y.Z`，按变化递增）；交付型惯用 CalVer，库 / 产品惯用 SemVer；登记于「路径、ID 与工程约定」节 |
   | 验收模式 | 默认 auto。`Acceptance mode`：auto 验证全绿自动走 accept 链，manual 验收由用户发起；登记于 runtime「治理配置」区 |

3. **生成（全新模式，默认并行分派）**：按回答生成填好的 17 治理文件（含 `sdd/runtime/` ×2）、1 治理工具 `sdd/tools/mdlint.sh` 与版本标记 `sdd/VERSION`（内容 = `${CLAUDE_SKILL_DIR}/../../.claude-plugin/plugin.json` 的 `version`），四路并行，各组自读所需规格，① CONSTITUTION + INDEX + INITIATIVE + `amendments/amend.md`（读 `references/constitution-design.md` 全文 + `references/command-specs.md` 生成骨架）② 命令 ×6（读 command-specs 命令规格表 + constitution-design「状态转换 × 文档同步矩阵」节，定点读取）③ 模板 ×4 与 `tools/mdlint.sh`、`sdd/VERSION`、`.githooks/pre-commit`、`README.md`（复制自 `templates/`、`scripts/`，版本标记取插件清单 version 写入，hook 含内嵌 mdlint 段与路由段骨架、另加可执行位；README 为运行说明，已存在则追加激活小节、不存在则创建） ④ OpenCode 适配 ×9（读 `references/opencode-adapter.md`，含 `sdd/runtime/opencode.md`）。**`sdd/runtime/claude.md` 与 `CLAUDE.md` 最后由主会话写**（引用全部生成物）。

   **治理形态分支（standalone 专属动作，在对应组生成后由主会话收尾执行）**：`.gitignore` 不写（inline 三行惯例照旧）；写 `.git/info/exclude` 排除清单七行（`sdd/`、`.claude/commands/sdd-*.md`、`.opencode/commands/sdd-*.md`、`.opencode/opencode.json`、`*.local.*`、`.worktree/`、`.export/`）；生成 `CLAUDE.local.md`（内容 `@sdd/runtime/claude.md`）；内层仓 `git init sdd`（如 `sdd/.git` 已存在则跳过）；内层 hook `scripts/pre-commit-inner.sh` 装 `sdd/.git/hooks/pre-commit` 加可执行位。组 subagent 回报工具缺失时按所用宪法规格「工具可用性实证」节处置（调用实证复核、重派一次）；环境不支持 subagents 或重派仍败时按组序串行生成，步骤不变。既有安装不走本步生成流程，校准按 `references/upgrade.md` §四（`runtime/claude.md` 同样最后写）。
4. **收尾**：对全部生成文件（含适配文件）按下方「四、验证与回报」完成 mdLint 与各项验证（零 error）、git 提交（inline 两笔 20+10；standalone 项目仓一笔中性 message 仅 `CLAUDE.md` + `AGENTS.md` + `README.md` + `.githooks/pre-commit`，内仓 `git -C sdd` 一笔全部治理资产）、计算初始化耗时与回报；两形态写 `.git/info/exclude` 排除行 `.export/`。既有安装收尾：校准按 `references/upgrade.md` §四-§五（复用全量验证，提交按实际变更分批）。

> **中断恢复**：会话中断后续跑时，已生成文件若与「四、验证与回报」清单吻合即视为本初始化产物，跳过前置检查的冲突判定；对照其清单补齐缺失文件、已验证项不重跑、必填项从已生成文件回读（项目名/定位见 `CLAUDE.md`），回读不到才询问；若存在清单外文件，照常停止报告冲突。升级与校准中断 → 直接重跑（幂等），细则见 `references/upgrade.md` §四。

## 三、文档结构（17 治理文件 + 1 治理工具 + 1 版本标记 + 1 门禁 hook + 1 README + 9 OpenCode 适配文件 = 30；standalone 不写 `.gitignore`、改生成 `CLAUDE.local.md`，一减一加同数 30）

```
<项目根>/
├── CLAUDE.md                      # 项目骨架（公开面：项目名 + 定位；inline 多一行 @sdd/runtime/claude.md）
├── CLAUDE.local.md                # ★ 仅 standalone：指针 @sdd/runtime/claude.md
├── AGENTS.md                      # 项目骨架（OpenCode 侧项目入口，两形态同文）
├── .gitignore                     # inline：本地文件不入库 *.local.*；standalone：不写此文件
├── README.md                      # 运行说明（含门禁激活行 `git config core.hooksPath .githooks`）
├── .githooks/
│   └── pre-commit                 # 提交门禁（先写回后断言 + 内嵌 mdlint 段；入库、core.hooksPath 激活）
├── .claude/commands/              # 6 命令，sdd- 前缀（命令唯一源）
│   ├── sdd-intake.md  sdd-start.md
│   ├── sdd-board.md  sdd-accept.md
│   ├── sdd-export.md  sdd-config.md
├── .opencode/
│   ├── opencode.json              # OpenCode 共享配置（lsp: true + instructions）
│   └── commands/                  # 6 命令存根（@ 引用 .claude/commands/ 同名文件）
└── sdd/
    ├── VERSION                    # 版本标记：初始化时插件清单 version（升级校准的回报基线，非治理文档）
    ├── CONSTITUTION.md            # SDD 治理宪法（根本法；不用 README.md，防执行者按默认习惯另建）
    ├── INDEX.md                   # 登记簿：Proposal 状态唯一权威 + P/T 发号计数器
    ├── INITIATIVE.md              # 构想池：构想唯一记录 + I 发号计数器
    ├── amendments/amend.md        # 修正登记簿 + A 发号计数器（决策反转追加式录入）
    ├── runtime/
    │   ├── claude.md              # Claude 侧 sdd 运行时骨架（治理活文档，规格见 references/command-specs.md）
    │   └── opencode.md            # OpenCode 补充壳（规格见 references/opencode-adapter.md）
    ├── templates/  proposal.md  spec.md  design.md  task.md
    └── tools/
        └── mdlint.sh              # 治理工具（非治理文档）：Markdown 规范校验
```

运行态目录不预建（见 `references/constitution-design.md`「层级与分区」）。

`.githooks/pre-commit` 为入库清单文件（提交门禁，契约见 `references/constitution-design.md`「校验」节，README 记激活行）；standalone 形态另装内层 `sdd/.git/hooks/pre-commit`（辖区变体，不入清单）、写 `.git/info/exclude` 六行排除清单、`git init sdd` 内层仓。

## 四、验证与回报

1. **失败处置（总则）**：任何验证失败，修复后必须重跑对应**全量**验证（mdLint 失败即对全部生成文件重跑，非仅复验出错项），全部通过方可进入下一步；禁止跳过任何验证步骤（明示豁免者除外）、禁止带病提交、禁止以「已修过」为由免检。
2. 文件齐全、结构正确、必填项已填（inline 30 文件：17 治理文件 + 1 治理工具 + 1 版本标记 + 1 门禁 hook + 1 README + 9 OpenCode 适配文件；standalone 同数 30，不写 `.gitignore`、改生成 `CLAUDE.local.md`）；`sdd/VERSION` 与插件清单 version 一致；`.githooks/pre-commit` 已生成且可执行、`git config core.hooksPath` 输出 `.githooks`（入库占清单，初始化提交经其实测；standalone 另有内层 `sdd/.git/hooks/pre-commit` 与 `.git/info/exclude` 排除清单）；README 含激活行；
3. 对全部生成文件运行 `sh sdd/tools/mdlint.sh sdd/ CLAUDE.md AGENTS.md README.md .claude/commands/ .opencode/commands/`（standalone 下追加 `CLAUDE.local.md`），零 error；
4. ID/状态机/矩阵在 CONSTITUTION、INDEX、INITIATIVE、模板、6 命令间交叉一致；
5. `git check-ignore -v .claude/settings.local.json .opencode/tmp.local.json`（后一文件名任取一个不存在的即可）→ 均命中；`git check-ignore .opencode/opencode.json` → inline 无输出（未被忽略）/ standalone 命中（排除清单生效）；
6. OpenCode 三段验证（`opencode` 未安装时整体跳过并在回报注明；其运行副产物被 `.opencode/.gitignore` 自忽略，不影响提交）：① 配置面——项目内 `opencode debug config` 输出含本项目 `.opencode/opencode.json`，其 `info` 含 `"lsp": true` 与 `instructions` 两路径；② 存根契约——存根 ×6 在位，frontmatter description 与 `references/command-specs.md` 命令规格表逐字一致，各存根 `@` 指向的 `.claude/commands/` 同名文件存在；③ 命令发现——`opencode run '/sdd-board'`，判据为退出码 0 且输出为与命令规格一致的看板摘要（提案总览或暂无提案说明）且不含「未定义命令」措辞；sdd-* 命令结构同构，一通俱通，输出未定义措辞或格式不符为失败；本段因模型或凭据未配置失败时跳过并在回报注明；
7. git 提交均显式列举文件路径添加、禁用 `git add -A` 与 `git add .`：inline 两笔，第一笔仅 20 清单文件（17 治理 + 工具 + VERSION + 门禁 hook，含 runtime ×2），消息固定 `chore: 初始化 SDD 需求治理体系（17 治理文件 + mdlint 工具 + 版本标记 + 提交门禁）`；第二笔仅 10 适配文件（`AGENTS.md` + `README.md` + `.gitignore` + `opencode.json` + 存根 ×6），消息固定 `chore: 适配 OpenCode（命令存根 @ 引用 + .opencode 共享配置 + 运行说明）`。standalone 两仓各一笔：项目仓仅 `CLAUDE.md` + `AGENTS.md` + `README.md` + `.githooks/pre-commit`，message 固定 `docs: 项目协作入口与提交门禁`（中性，无 sdd 字样）；内仓 `git -C sdd` 提交 `sdd/` 全部，消息同 inline 第一笔。除清单文件外禁止创建任何其他文件（评审/提示词等用户文档不入库）；
8. 冒烟演练默认**不执行**，初始化完成后待命 `/sdd-intake` 接首个真实需求；后续冒烟（用户在 opencode TUI 手动）：输入 `/` 查看命令补全、执行任一只读命令（如 `/sdd-board`）、问「本项目会话必读是什么」应答 CONSTITUTION → INDEX → INITIATIVE（验证 runtime 注入链路：inline 为 `CLAUDE.md` @ 引用，standalone 为 `CLAUDE.local.md`）；
9. 最终回报：文件清单 + commit hash（inline 两个 / standalone 两个仓各一）+ mdLint 结论 + 各项验证结论 + 初始化耗时（总时长，人类可读格式）+ 门禁 hook 结论（激活状态含 standalone 内层 hook）+ 治理形态 + 模式（全新 / 升级）与版本去向（升级回报项见 `references/upgrade.md` §五）。
