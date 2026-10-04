# 任务：在当前项目初始化 SDD 需求治理体系并适配 OpenCode

## 一、背景与目标

目标项目为 Vibe Coding 模式：AI 主导编码，需求对话式动态探索、粒度不一、高频变更；项目尾声或结束时，可归档干净完整的需求与设计文档供新项目复用，全部治理文档由 AI 按工作流自动维护。

本提示词为可移植初始化器：任意项目会话中输入，即生成治理体系并交互完成初始化；自然包含 OpenCode 适配（规格见 §7），实现 Claude Code ⇄ OpenCode 无缝衔接开发。

运行前提：POSIX 环境（macOS/Linux，sh/awk/perl 可用，`mdlint.sh` 零依赖即指此）；非 POSIX 平台须先自备等价工具，否则禁止开工。

以下治理设计已全部确认，**直接执行，禁止重新设计、增删决策**。

> 提示词版本：2.1.3（与插件 `plugin.json` 的 `version` 同步；可移植环境下为 `sdd/VERSION`（`version+full`）的值源）
> **TL;DR**：① 前置检查（判定全新 / 升级模式与治理形态）→ ② 问必填项（仅全新，含治理形态，默认 inline 且 init 后不可切换）→ ③ 全新：四路并行生成 31 文件（standalone 32）；升级：按 §8 就地合并 → ④ 全量验证后提交（inline 全新两次；standalone 两仓各一笔；升级按实际变更）。
> **三条禁忌**：禁止擅自覆盖既有文件；禁止重新设计、增删决策；禁止跳过任何验证。

## 二、初始化流程（四步，顺序固定）

1. **前置检查**：
   - 记录起始时间戳（`date +%s`），收尾计算初始化耗时
   - 当前目录为项目根；非 git 仓库则自动执行 `git init`
   - 冲突检测：已存在 `sdd/`、`CLAUDE.md`、`CLAUDE.local.md`、`.claude/commands/sdd-*.md`、`AGENTS.md`、`.opencode/` 或 `.git/hooks/pre-commit` 任一 → **停止并报告冲突清单**，由用户决定，禁止覆盖（标准处置二选一：跳过冲突项继续，或用户明示删除后重建；其余处置须用户逐项明示）；命中项构成全套签名文件（判定清单见 §8）时经用户确认转**升级模式**（就地合并），部分存在仍按本条停止，禁止补齐后覆盖。治理形态按 `sdd/` 是否为独立 git 仓判定（standalone / inline）；既有低版本安装一律视为 inline
   - `opencode` 可用性：不可用则照常生成全部文件、最终回报中提示安装，禁止自动安装、不阻塞
2. **询问必填项**（升级模式跳过本步，改按 §8 回读）：一次性向用户列出下表，等待回答；未回答项用默认值，必填项未获回答则再次询问、仍拒答则停止（启动日期不询问，`date +%F` 实取）：

   | 项 | 必填 | 默认值 / 说明 |
   |---|---|---|
   | 治理形态 | 可默认 | 默认 inline。选项行固定：`inline 仓（内联，随项目仓，默认）/ standalone 仓（独立，单独治理仓；init 后不可切换，项目需对外无痕或治理不入项目仓时选此）`；形态 init 后不可切换 |
   | 项目名 | 可默认 | 默认 = 当前目录名；用于 `CLAUDE.md` 与 `AGENTS.md` 标题 |
   | 项目定位一句话 | 必填 | `CLAUDE.md` 首行：一句话说明项目是什么、目的 |

3. **生成（全新模式，默认四路并行）**：按回答生成填好的 19 治理文件（含 `sdd/runtime/` ×2）、1 治理工具 `sdd/tools/mdlint.sh` 与版本标记 `sdd/VERSION`（内容 = 本提示词顶部版本 + `+full`；经插件调用时取插件清单 `version` + `+full`），用 subagents 按文件组分派并行，各组自读本提示词对应章节。

   | 组 | 生成物 | 自读章节 |
   |---|---|---|
   | ① | CONSTITUTION、INDEX、INITIATIVE、`amendments/amend.md` | §4 全文 + §5 生成骨架 |
   | ② | 命令 ×7（`.claude/commands/`） | §5 命令规格表 + §4「状态转换 × 文档同步矩阵」（定点读取） |
   | ③ | 模板 ×4（按 §5 骨架生成）、`tools/mdlint.sh`（按 §4「校验」节实现并过自测向量）、`sdd/VERSION`（写版本值 `X.Y.Z+full`）、`.git/hooks/pre-commit`（按 §4「校验」节提交兜底生成并加可执行位）、archive/README（按 §4「归档」节生成） | §4「归档」+「校验」 |
   | ④ | OpenCode 适配 ×11（含 `sdd/runtime/opencode.md`） | §7 全文 |

   **`sdd/runtime/claude.md` 与 `CLAUDE.md` 最后由主会话写**（引用全部生成物）；环境不支持 subagents 时按组序串行，步骤不变。写 `sdd/` 下文档的组完成时各自先跑 mdLint 自查。升级模式不走本步生成流程，改按 §8 就地合并（两路并行，`runtime/claude.md` 同样最后写）。

   **standalone 形态专属动作**（治理形态选 standalone 时，主会话在生成组收尾执行）：`.gitignore` 不写（inline 三行惯例照旧）；写 `.git/info/exclude` 六行排除清单（`sdd/`、`.claude/commands/sdd-*.md`、`.opencode/commands/sdd-*.md`、`.opencode/opencode.json`、`*.local.*`、`.worktree/`）；生成 `CLAUDE.local.md`（内容 `@sdd/runtime/claude.md`）；`git init sdd` 内层仓；内层 hook 按 §4「校验」节内层变体生成，装 `sdd/.git/hooks/pre-commit` 加可执行位。

4. **收尾**：对全部生成文件（含适配文件）按 §6 完成全量验证（零 error）、git 提交（inline 两笔 21+10；standalone 项目仓一笔中性 message 仅 `CLAUDE.md` + `AGENTS.md` + 内仓 `git -C sdd` 一笔全部治理资产）、计算初始化耗时与回报。升级模式收尾按 §8（复用全量验证，提交按实际变更分批）。

> **中断恢复**：会话中断后续跑时，已生成文件若与 §6 清单吻合即视为本初始化产物，跳过前置检查的冲突判定；对照其清单补齐缺失文件、已验证项不重跑、必填项从已生成文件回读（项目名/定位见 `CLAUDE.md`），回读不到才询问；若存在清单外文件，照常停止报告冲突。升级模式中断 → 直接重跑升级（幂等，见 §8）。

## 三、文档结构（19 治理文件 + 1 治理工具 + 1 版本标记 + 11 OpenCode 适配文件 = 31；standalone 再 +`CLAUDE.local.md` = 32）

```
<项目根>/
├── CLAUDE.md                      # 项目骨架（公开面：项目名 + 定位；inline 多一行 @sdd/runtime/claude.md）
├── CLAUDE.local.md                # ★ 仅 standalone：指针 @sdd/runtime/claude.md
├── AGENTS.md                      # 项目骨架（OpenCode 侧项目入口，两形态同文）
├── .gitignore                     # inline：本地文件不入库 *.local.*；standalone：不写此文件
├── .claude/commands/              # 7 命令，sdd- 前缀（命令唯一源）
│   ├── sdd-intake.md  sdd-finalize.md  sdd-split.md
│   ├── sdd-start.md  sdd-board.md  sdd-accept.md  sdd-archive.md
├── .opencode/
│   ├── opencode.json              # OpenCode 共享配置（lsp: true + instructions）
│   └── commands/                  # 7 命令存根（@ 引用 .claude/commands/ 同名文件）
└── sdd/
    ├── VERSION                    # 版本标记：本提示词 / 插件清单 version（升级校准的回报基线，非治理文档）
    ├── CONSTITUTION.md            # SDD 治理宪法（根本法；不用 README.md，防执行者按默认习惯另建）
    ├── INDEX.md                   # 登记簿：Proposal 状态唯一权威 + P/T 发号计数器
    ├── INITIATIVE.md              # 构想池：构想唯一记录 + I 发号计数器
    ├── amendments/amend.md        # 修正登记簿 + A 发号计数器（决策反转追加式录入）
    ├── runtime/
    │   ├── claude.md              # Claude 侧 sdd 运行时骨架（治理活文档，规格见 §5）
    │   └── opencode.md            # OpenCode 补充壳（规格见 §7）
    ├── templates/  proposal.md  spec.md  design.md  task.md
    ├── tools/
    │   └── mdlint.sh              # 治理工具（非治理文档）：Markdown 规范校验
    └── archive/README.md          # 归档区说明（只读 + 四产物 + REUSE-GUIDE 用法）
```

运行态目录不预建（见 §4「层级与分区」）。

另生成不入库的 `.git/hooks/pre-commit`（R8 提交兜底，见 §4「校验」节）；standalone 形态另装内层 `sdd/.git/hooks/pre-commit`（辖区变体）、写 `.git/info/exclude` 六行排除清单、`git init sdd` 内层仓。不入 31 / 32 文件清单。

## 四、治理体系核心设计（生成 `CONSTITUTION.md`，写入宪法，禁止改动）

宪法文件 = `# <项目名> SDD 治理宪法` + 本节全部小节逐字（受理与分流、构想池、自治边界为正文节；并行开发为可选节）+ 末尾生效日期（`date +%F`）。

### 层级与分区

- 三层实体：**Initiative（I-XXX，总纲）**，模糊需求的产品层澄清与路线图，不进状态机；**Proposal（P-XXX）**，可独立验收的开发单元（基础件或功能块），真正的开发循环从这里开始；**Task（T-XXX，可数十个、可分组）**，design 任务清单内，禁止单独建文件。
- Proposal 粒度：必须是一个可独立验收的开发单元，禁止以产品版本形态立项（如「XX 第一版/首版」标题）；产品级、多交付物或模糊需求先入构想池拆解为总纲，再拆出 Proposal；两级拆分（I 拆 P、P 拆 T）不跨层。
- 受理两路：单交付物需求由 `/sdd-intake` 直接发 P（无 source）；多交付物或模糊需求先入 `INITIATIVE.md` 立 I，拆解后发 P（frontmatter `source: I-XXX`）。
- 分区治理：`sdd/exploring/`（探索区，格式宽松，含探索底稿 `P-XXX.md` 与 `journal.md`：底稿自提案创建起持续落盘探索与讨论过程，存活至验收通过或 rejected 终结，定稿不冻结）与 `sdd/specs/`（稳定区，格式严格、变更留痕，每提案一目录：`spec.md` 与 `design.md`）物理分离；修正隔离在 `amendments/` 与构想池；归档只从稳定区取材。
- **探索档案 `journal.md`**：项目内永久档案（不入归档四产物），按提案分节追加，即 `## P-XXX <标题>` + 状态轨迹行 + 底稿除 frontmatter 外正文原样；只追加与原位标注、不重写历史。开发中新情况的探索讨论过程，属当前提案范围内且形成新 Task 的，按主题补录底稿相应小节（不必然追加于末尾）；结论写 spec（changelog + version），过程写底稿。验收通过或 rejected 终结时底稿整稿入档后删除，on-hold 底稿留原地。
- **不预建**运行态目录：exploring/、specs/、`journal.md` 均动态形成；`INITIATIVE.md` 与 `amendments/amend.md` 由初始化生成。

### 权威源、ID 与日期

- INDEX 是 Proposal 状态**唯一权威源**，状态变更即时同步（操作即同步，不攒批）；`INITIATIVE.md` 是构想唯一记录；Task 状态唯一权威 = design 任务表；规格版本唯一维护处 = spec frontmatter `version`。
- I/P/T/A 四套编号各自全局递增，**永不复用、永不重排**（rejected 也占号）；P/T 发号统一在 INDEX 顶部计数器，I 号计数器位于 `INITIATIVE.md` 顶部，A 号计数器位于 `amendments/amend.md` 顶部；取号后立即递增写回。
- **日期规则**：治理文档一切日期唯一源 = 执行写入的会话所在机器的系统日期（本地时区）；写入前必须以 `date +%F`（或等价）实取；禁止凭记忆或上下文推断；粒度 YYYY-MM-DD。

### 状态机（禁止跳跃）

- Proposal：`exploring → specified → implementing → verifying → accepted`；旁路 `on-hold`（任意态可入可回，排队/搁置两用）、`rejected`（终态，INDEX 备注列写原因）。
- Task：`todo / doing / blocked / done / dropped`（done、dropped 为终态；doing 即锁定，禁重复派发）；design：`draft → finalized`。
- **代码与 Task 绑定**：项目功能实现代码必须挂在 design 任务清单的具体 Task 上；Task 未拆分（exploring/specified）禁止写实现代码，仅产出探索与规格文档；代码随 Task 执行写入；验收未过的缺陷修复提交按 footer 规则记 `Fixes: T-XXX` 回链 Task（standalone 形态项目仓无痕化不记 footer，改以 design 任务详情回填关联）。

### 受理与分流

- **维护/需求分类三问**：① 行为变化？（新能力/改变对外行为 = 需求；恢复既定或不改变 = 维护）② 方案空间？（存在真实选择 = 需求；路径唯一 = 维护）③ AC 自明性？（需协商定义 = 需求；自明 = 维护）。任一命中需求特征即立项；三问全维护 → 直接做，不立项。
- 分类四保险：**默认偏维护**（判不准一律按维护）；**停损升级**（维护中冒出方案选择或范围膨胀 → 当场停、补立项）；**口令优先**（分类仅为建议，用户一句终局）；**amendments 旁路**（维护暴露决策/设计错误 → 走 A-XXX）。例子锚点：改按钮颜色、修 typo、升依赖 = 维护；国际化、暗色主题、OpenAPI 文档 = 需求（XS 级）。
- **单/多交付物三问**：① AC 可写性（现在就能写出 1-3 条可核对的验收标准吗？）② 边界可划性（范围内外现在就能划清吗？）③ 交付物同质性（单一功能块，还是天然含多个异质交付物？）≥2 问指向「要拆」→ 入构想池；否则直接发 P。
- 同类重复不算异质（「给 10 个字段加校验」是一个 P 的 10 个 Task）；拿不准时兜底一问用户：「想一口气做完，还是先立框架分期做？」
- **误入池出口**：池内拆解后发现实为单交付物 → 关闭 I 条目，直接发 P（无 source）；直接 P 发现要拆 → 探索产物回填构想池升格。判错可恢复，均非事故。
- **判定示例**：用户登录功能，大功能但复杂性全在工程层（认证选型），产品结构上是一块，单交付物，直接发 P；完整账号体系（个人/企业、SSO、组织权限），产品级构想需路线图，入池立 I 拆解。

### 状态转换 × 文档同步矩阵

| 转换 | 必做操作 |
|---|---|
| intake 判定单交付物 →exploring | 模板建 `exploring/P-XXX.md` + INDEX 加行 |
| intake 判定多交付物 →构想池 | `INITIATIVE.md` 立 I 条目（原文保留 + 路线图） |
| I 拆出发号 →exploring | 模板建 `exploring/P-XXX.md`（frontmatter `source: I-XXX`）+ INDEX 加行 |
| exploring→specified（/sdd-finalize） | 建规格（被否备选录入否决记录）+ 底稿保留至验收 + INDEX 更新 |
| specified→implementing（/sdd-split） | 建 design 骨架 + 任务入清单 + 切 `.worktree/<标题 slug>` worktree（分支 `dev/<标题 slug>`） + INDEX 更新 |
| 任一 Task 状态变化 | 仅更新 design 任务表 + 任务详情小节回填 |
| 全任务 done →verifying | test 串行检查（他 P 持有 test 分支则本次转换挂起：P 留在 implementing，任务表保持全 done，worktree 与 dev 分支保留，待其 accept 后重走本行）+ 从当前 main 切出 `test/<标题 slug>` 合并 `dev/<标题 slug>`（冲突一律在 test 解决；删除 worktree 与 dev 分支）+ 交付 hash 记入 design + INDEX 置 verifying + 列出验收清单表格（五列：AC / 验收标准 / 证据 / 人工测试步骤 / 结论；验收标准与 spec 逐字一致，会话输出不落盘）+ 提示人工测试（主工作区检出 test）；测试通过后 /sdd-accept |
| verifying→accepted（/sdd-accept） | AC 逐条**以实际证据**核对验收清单表格（结论通过置 ✅；未全过不置 accepted，Task 保持 done）+ 全过后主工作区检出 main + 合并 `test/<标题 slug>` → main（发布）+ design 置 finalized + 底稿正文追加 journal 后删除 `P-XXX.md` + 通过的验收清单表格追加 journal + INDEX 更新 + CHANGELOG 增补本版条目（三源锚定、四类、不含治理 ID；standalone 落外层中性 message）+ 治理提交（standalone 经 `git -C sdd` 落内层仓）后打 tag（永远打在外层项目仓）+ 删除 test 分支 + 完成回报固定建议「回看需求组拆下一个」 |
| I 完结 | 组内全部 P accepted → I 条目标完结（归档时并入 `requirements.md` 后移除） |
| →on-hold / rejected | INDEX 改状态 + journal 追加处置行（rejected 须写原因）；rejected 底稿整稿入档（标注 rejected）后删除，on-hold 底稿留原地；rejected 分环节清理分支：未建分支（exploring / specified）仅删文档，implementing 删 worktree 与 `dev/<标题 slug>`，verifying 删 `test/<标题 slug>`（main 零沾染）；on-hold worktree 与分支挂起保留 |
| 定稿后需求变更 | 规格正文 + changelog + version 递增（v1.0 → v1.1）+ 受影响 Task 评估，禁静默覆盖 |
| 归档（/sdd-archive） | INDEX 置「已归档 + 日期」+ 四产物 + 完结 I 条目并入 `requirements.md` + sdd 全区只读 |

### 会话微流程 R1-R10（写入宪法）

- **R1** 冷启动读 CONSTITUTION → INDEX → INITIATIVE，输出状态摘要（含构想池概览：活跃 I 数、待梳理条目、未立项里程碑）
- **R2** 新想法当场分类（维护/需求三问）：维护直接做并回报；需求一律经 /sdd-intake 受理，单交付物直接发号，多交付物先落构想池；当前工作永不因新想法自动中断
- **R3** 探索期自顶向下、先发散后收敛、逐层留痕（实时写入底稿，用户给出内容同样落盘；过程全程落盘底稿，结论演进走 spec changelog）
- **R4** 被否备选禁删，记入提案「否决记录」，留「方案 + 一句话原因」
- **R5** 实现中新需求：小则 Task 内消化回填，改验收标准则停手上报由用户定
- **R6** 更新任务表 + 回填 design；全任务 done 列出验收清单表格并提示人工测试；测试通过后 /sdd-accept
- **R7** 关键节点（拆任务/定稿/验收/归档）显式建议对应命令保人工确认；accept 完成回报固定建议回看需求组
- **R8** 不改 templates/，tools/ 仅随 Markdown 规范演进修改；稳定区禁自由格式；归档后只读；写/改任何 sdd 文档后必须运行 mdLint，零 error 方可回报完成（warning 逐条确认或忽略）
- **R9** 跨周期修正禁只改代码，走 amendments/
- **R10** 分支开发主干发布：split 从 main 切 `dev/<标题 slug>` 并建 worktree 开发（分支名不含治理 ID 与治理文件名），代码在分支、治理文档只在主干由主会话写，test / dev 检出中 sdd/ 只读；分支提交以 Task 为界、Task 完成即提交；test 串行：全流程同时至多一个 P 持有 test 分支，全任务 done 而他 P 持有 test 时留在 implementing 等待（任务表保持全 done，worktree 与 dev 分支保留），待其 accept 后再行 verifying 转换；全任务 done 从当前 main 切 `test/<标题 slug>` 合并 dev 代码（冲突一律在 test 解决），删除 worktree 与 dev 分支，列验收清单表格交用户在主工作区检出 test 人工测试；主干冻结：验收期（test 切出至 accept）内 main 代码不前进（治理文档主干直写照旧），一切修复（无论缺陷源自哪个 P 的范围，含不进 Proposal 的维护性修复）都落在当前 `test/<标题 slug>`，随本 P accept 一并进 main，验收期外维护照旧直接落 main；accept 时 AC 逐条以实际证据核对填入验收清单表格（未全过不置 accepted，Task 保持 done）→ 主工作区检出 main → 合并 test → main 发布 → 治理提交 → 打 annotated tag（版本格式首次询问定型：CalVer 验收日或 SemVer，信息取本次 CHANGELOG 条目首行）→ 删 test 分支；rejected 分环节清理（未建分支删文档 / implementing 删 dev 与 worktree / verifying 删 test），main 零沾染，on-hold 挂起保留；提交信息 title 与 body 不含治理 ID；需要引用治理实体时，在 footer 区（body 后空一行、逐行）按 trailer 惯例记，关键词随本提交对实体的作用而定，无引用则不写（Task 完成 → `Closes: T-XXX`，accept 验收提案 → `Closes: P-XXX`，验收阶段修复已完成 Task 的缺陷 → `Fixes: T-XXX`，一 Task 多提交时的非收尾提交等 → `Refs: T-XXX`）；开发过程中的自我修正不属修复语义，随所在 Task 完成提交记；Task 完成只记代码侧提交，主干治理提交不重复记；footer 区可并存项目自有 trailer，也可有多个 trailer；standalone 形态本段整体替换为「项目仓提交不含治理 ID、治理引用与 sdd 字样（无痕化），内层治理仓提交不受此限」；代码提交前须通过项目提交前校验（lint、format、测试等，以项目工程约定为准）；push 永远手动。

### 自治边界（判断自动，动作守门；写入宪法）

| 层级 | 事项 |
|---|---|
| 自动执行，做完告知 | 维护/需求分类判断、维护直接做、新想法落池、三问执行、XS 产物极短化、R1 摘要、board 聚合 |
| 判断 + 明示理由，可一句话推翻 | 建议立项、on-hold 排队建议 |
| 永远用户守门 | 发号（P）、授予 I、finalize、accept、停损升级、archive、决策反转入册（A）、写实现代码 |

### Markdown 书写规范（宪法此节以本节为唯一规格源；`mdlint.sh` 按此实现）

- **语法总则**：遵循 CommonMark/GFM 语法，结构符号一律半角（列表标记、链接括号、标题 `#`、表格 `|` 与 `-` 分隔行）；强调一律 `*` 禁 `_`；行内代码反引号与加粗 `**` 成对闭合- **混排层**：中文正文标点全角（，。：；？！、（）「」）且成对闭合；中文与英文/数字/半角符号之间加一个半角空格（× 表倍数时与数字紧贴，如「模板 ×4」），标点/代码边界处不加（按渲染后中英边界判断；强调与行内代码标记不构成边界）；中文正文引用标记只用「」或半角直引号 ""；半角引号等半角符号与中文相邻时，两侧须加空格；命令、路径、文件名（无论单独、带路径或以 `.` 开头）、键名组合、代码用行内代码包裹；片段含 `/`、`~`、`*`、`_`、`<`、`&`、`|` 任一字符的亦包裹；治理 ID（I-001 / P-001 / T-001 / A-001 形态）一律裸写，禁入行内代码；带 scheme 前缀的链接地址（http、https、ftp、mailto 等）裸写且优先于字符判据，交渲染器自动链接；其余片段一律裸写，单词化的动作、配置与产品指称视同术语；破折号「——」避免使用，解释性插入宁用「：」「，」「（）」或语言描述；同一句子内、同一层级不重复使用冒号（半角 `:` 与全角 `：` 同计，行首标签与 `type:` 前缀计入，括注内与表格字段除外）；commit message 与 tag message 同此规则；省略号「……」、空值占位单个 `—`（仅表格与字段）、范围号紧贴 `-`（`R1-R10`）、禁用 `–`；列表项短语结尾不加标点、整句加中文句号；表格单元格不加句号；专有名词保持原大小写（README、`CLAUDE.md`）；无序列表统一 `-`、有序列表统一 `1.`
- **语义层**：算式与维度一律紧凑（`1+2`、`3-2=1`、`4×5`、`4×4 矩阵`、`n×m`）；`+`、`-`、`=` 不机械检查（区间、复合词、散文等号合法）；× 连接中文两侧加空格（状态转换 × 文档同步）；倍数写「模板 ×4」；计数比一律 `/`（3/8），`×` 禁表计数比或分隔；流程用「→」；并列用「与/·」
- **校验**：`sh sdd/tools/mdlint.sh <文件或目录>`（POSIX sh + awk + perl，macOS 自带零依赖）。检查集按 AI 作者错误分布校准，限于书写形态，内容治理不入检查集。error：反引号或 `**` 行内不配对、全角圆括号/直角引号文件级不配对；warning：中英文粘连（剥离行内代码后）、无序列表标记非 `-`、表格行列数与表头不一致（GFM 会静默补空或丢弃）、行内代码内出现治理 ID（执法 ID 禁包规则）。检查豁免代码围栏；行内代码内容除治理 ID 检查外豁免。零 error 方可回报，warning 逐条确认或忽略。提交兜底：sdd-init 安装 `.git/hooks/pre-commit`（三端通用：Claude Code、OpenCode 与人工提交同受约束），staged 文件落于辖区（`sdd/` 下、`CLAUDE.md`、`CHANGELOG.md`、`.claude/commands/`、`AGENTS.md`、`.opencode/commands/`）时整体跑本工具，有 error 非零退出阻止提交；warning 不拦，工具缺失静默放行。standalone 形态另装 `sdd/.git/hooks/pre-commit` 内层变体（辖区 = 内层仓全部 staged `.md`），治理提交同受约束。

`mdlint.sh` 实现后必须以下列向量自测全过方可视为达标：

| 自测向量 | 预期 |
|---|---|
| 行内反引号单只不闭合 | error |
| 中文与英文直接粘连（剥离行内代码后） | warning |
| 上述任一情形位于代码围栏或行内代码内 | 豁免 |
| 行内代码内包裹治理 ID（如反引号内写 T-001） | warning |
| 「模板 ×4」倍数紧贴写法 | 无输出 |

`pre-commit.sh` 实现后必须以下列向量自测全过方可视为达标（临时仓库：置 `sdd/tools/mdlint.sh`、hook 装入 `.git/hooks/` 并加可执行位）：

| 自测向量 | 预期 |
|---|---|
| 无 staged 文件 | 静默退出 0 |
| staged 辖区 `.md` 含 error | 非零退出 + stderr 列出问题 |
| staged 辖区 `.md` 干净或仅 warning | 0 放行 |
| staged 辖区外 `.md` 含 error | 0 放行 |
| `sdd/tools/mdlint.sh` 缺失 | 静默退出 0 |

内层变体（`pre-commit-inner.sh`）过同套向量，路径映射适配：临时仓根即治理根，mdlint 置 `tools/mdlint.sh`、staged 路径无 `sdd/` 前缀。

### 修正机制（amendments/，跨周期）

- **登记簿**：`amendments/amend.md`（初始化生成），条目式追加，只录**已完结提案（accepted 及之后）**实现后被推翻或替换的决策反转；活跃提案内的否决与修正留在提案自身文件（否决记录、关键决策表 + changelog）。决策反转归用户守门，AI 仅可建议。
- **条目格式**：`### A-XXX <标题>（YYYY-MM-DD）` 行 + `关联：P-XXX / T-XXX` 行（多关联「、」分隔，无关联省略该行）+ `状态：active | superseded by A-YYY` 行 + `**决策**`（一句话）、`**理由**`、`**影响范围**` 三个加粗标签段。被替换条目仅原位改状态行，其余内容不动；A 号永不复用。
- 跨周期替换四步：① 新建条目说明替换方案与原因 ② 旧条目原位改状态 superseded by 新 A ③ 更新受影响规格（升版 + changelog）与 design 关键决策表 ④ 评估 INDEX 中依赖该决策的其他提案。

### 构想池（`INITIATIVE.md`）

- **地位**：构想唯一记录；顶层计数器 `next-I`；文件常态只保留活跃需求组。
- **I 条目格式**：

```
## I-XXX <一句话需求>（YYYY-MM-DD · 活跃 | 完结 | 丢弃）
> 原始念头：<用户原话逐字保留>
- 产品澄清：<对话沉淀>
- 路线图：<里程碑 / 子产品顺序>
```

- **不记录 P 指向**：组归属由 P frontmatter `source` 推导，避免双重记账。
- **raw 便签**：未成熟念头为无编号条目，随时可删除；梳理成熟原地升格为 I。
- **滚动立项**：accept 后回看需求组拆下一个；组内全部 P accepted → I 标完结。
- **插单**：新想法落池不打断当前工作；不立刻做的 P 置 on-hold 排队。

### 并行开发（可选节）

/sdd-start 默认单智能体一步到位；仅用户明确要求时切「派发-回收」两段式：主会话组装自包含任务简报（任务+验收标准+规格/设计节选）派发（Claude Code 以 todo 承载；OpenCode 会话以对话分派替代，规则相同）；回收逐条核验、统一更新。约束：sdd/ 文档只允许主会话写入，子智能体只读文档、写代码、对话回报，发现规格问题回报主会话走 R5。

### 归档（/sdd-archive）

四产物：`requirements.md`（仅 accepted 项、剔 changelog/frontmatter、rejected 不出现，其信息由「范围外」章节承载，并含完结 I 条目内容作为需求来源章节）；`design.md`（整合全部 finalized design、剔任务表等过程内容）；`amendment-log.md`（整合全部修正案，按主题分组，保留完整 superseded 生命周期链）；`REUSE-GUIDE.md`（四步：归档时 AI 可按域或模块对 `requirements.md` 自由分组组织，无需预定义域枚举；在新项目安装 sdd 插件（marketplace `star-plugins`）并执行 `/sdd:sdd-init` 生成治理体系 → 逐提案比对差异（采纳/调整/排除，排除必须写入新项目修正记录说明原因）→ 参照旧设计制新设计（冲突时优先参考 superseded 链防重蹈覆辙）→ 正常推进）。

## 五、命令、模板与语言规范

- 7 命令统一 `sdd-` 前缀；每命令正文必含：角色、前置检查、动作序列、完成回报格式，正文中文；**frontmatter description 英文**；均支持 `$ARGUMENTS`（约定见下表）；写 sdd 文档的命令（intake/finalize/split/start/accept/archive）在完成回报前必须运行 mdLint 且零 error；命令与状态的对应关系以宪法「状态转换 × 文档同步矩阵」为唯一来源；**description 与参数约定以本节命令规格表为唯一来源**，`CLAUDE.md` 命令一览表、各命令 frontmatter、.opencode 存根描述一律由此复制，禁止另编。

  | 命令 | description（英文，frontmatter 原样） | 触发时机 | $ARGUMENTS 约定 | 动作依据（矩阵） |
  |---|---|---|---|---|
  | sdd-intake | Capture a new requirement and shape it into initiatives or proposals | 新需求受理（含插单与回看拆解） | 可选：需求描述 | 先跑维护/需求分类三问，判维护直接做并结束；再按单/多交付物分流：直接发 P 或立 I 拆解 |
  | sdd-finalize | Finalize an exploring proposal into a spec | 探索定稿 | 可选：P-XXX | exploring→specified 行；执行前过软门自查 |
  | sdd-split | Split a finalized proposal into design tasks | 定稿后拆任务 | 必填：P-XXX | specified→implementing 行 |
  | sdd-start | Implement tasks from the design task list | 实现推进（默认单 Agent 开发，可派发多 Agent 并行开发） | 可选：P-XXX（批量推进该提案全部未完成 T）/ T-XXX（仅推进该 Task，并行派发用）；缺省推进下一个 todo T | 接 P-XXX：从首个未完成 T 起顺序推进（doing → 实现 → 回填 → done）至全 done；接 T-XXX：仅该 Task；缺省：下一个 todo T；任一 Task 状态变化行；全任务 done → 执行 verifying 转换（见矩阵：合并 dev → test、删 worktree 与 dev 分支、交付 hash、列验收清单表格）+ 提示人工测试（主工作区检出 test）；测试通过后 /sdd-accept |
  | sdd-accept | Verify acceptance criteria and mark the proposal accepted | 全任务 done 后验收 | 必填：P-XXX | verifying→accepted 行（含 CHANGELOG 增补与打 tag）；完成回报固定建议「回看需求组拆下一个」 |
  | sdd-board | Show initiative and proposal status overview | 查看状态（只读） | 可选：I-XXX / P-XXX | 无矩阵行：读 INDEX + INITIATIVE + design 任务表输出摘要（含需求组聚合），不改任何文档 |
  | sdd-archive | Archive accepted proposals into the archive area | 归档 | 可选：P-XXX（缺省全部 accepted） | 归档行 |

- 模板四件套（sdd/templates/ 下固定文件；P-XXX/T-XXX/I-XXX 为占位，建文件时替换为实际号；`source` 行仅提案源自 I-XXX 时生成，独立提案删除此行），**骨架即规格**，见下。**设计是实现的副产品，不是事前作文**：定稿后建骨架、每 Task 完成回填、verifying 时补全置 finalized。

  **`proposal.md`**

  ```markdown
  ---
  id: P-XXX
  source: I-XXX
  type: proposal
  updated: YYYY-MM-DD
  ---
  # P-XXX <标题>
  ## 原始叙述
  （用户原话逐字保留）
  ## 已知信息与约束
  ## 候选方案
  （方案 A…：至少 2 个方向，各含优缺点/倾向；含至少 1 个保守或非常规方案）
  ## 开放问题
  ## 否决记录
  （方案 + 一句话原因）
  ## 变更记录
  | 日期 | 变更 |
  | --- | --- |
  ```

  **`spec.md`**

  ```markdown
  ---
  id: P-XXX
  source: I-XXX
  type: spec
  version: v1.0
  updated: YYYY-MM-DD
  ---
  # P-XXX <标题>
  ## 背景
  ## 用户故事
  ## 范围内
  ## 范围外
  ## 验收标准
  AC1：<可核对表述>
  AC2：…
  ## 边界与异常
  ## 依赖与关联
  ## 变更记录
  | 版本 | 日期 | 变更 |
  | --- | --- | --- |
  ```

  **`design.md`**（方案概述引 A-ID）

  ```markdown
  ---
  id: P-XXX
  type: design
  status: draft
  updated: YYYY-MM-DD
  ---
  # P-XXX <标题>设计
  ## 方案概述（引 A-ID）
  ## 接口
  ## 数据
  ## 关键流程
  ## 关键决策表
  | 决策 | 选项 | 选择 | 理由 | 关联 |
  | --- | --- | --- | --- | --- |
  ## 任务清单
  | 任务 ID | 标题 | 状态 | 分组 | 备注 |
  | --- | --- | --- | --- | --- |
  ## 任务详情
  ### T-XXX <标题>
  （按需回填：说明 / 实现记录）
  ```

  **`task.md`**（Task 条目格式定义，非任务文件）

  - 表行字段顺序：`T-XXX | 标题 | 状态 | 分组 | 备注`
  - 状态合法转换：`todo → doing → blocked → todo / done`；`done`、`dropped` 为终态；doing 即锁定，禁重复派发
  - 详情小节格式：说明（依据规格/设计节选）→ 实现记录（完成时回填：做法 + 证据）；完成判据 = 对照 spec 相关 AC 条目，验收核对统一在 /sdd-accept 进行（验收项不属于 Task）
  - 子智能体回报格式：做了什么 / 验收逐条结论 / 问题与规格偏差（走 R5 上报主会话）

- **`INITIATIVE.md` 生成骨架**（构想池，构想唯一记录）：

  ```markdown
  # 构想池

  > 计数器：next-I: 001
  > 条目格式见 CONSTITUTION「构想池」节；raw 便签无号，梳理成熟原地升格为 I。

  （暂无活跃构想）
  ```

- **`amendments/amend.md` 生成骨架**（修正登记簿 + A 计数器）：

  ```markdown
  # 修正案（Amendments）

  > 计数器：next-A: 001
  > 只录已完结提案实现后被推翻或替换的决策反转，追加式录入；条目格式与替换流程见 CONSTITUTION「修正机制」节。

  （暂无修正案）
  ```

- **`CLAUDE.md` 项目骨架**（公开面，内容固定，与 runtime 同批最后由主会话写）：`# <项目名>` + 项目定位一句话（首行）。公开内容零 sdd 痕迹；形态差异仅一行，inline 末尾追加 `@sdd/runtime/claude.md`（Claude Code 对该 @ 引用注入 runtime 规则全文），standalone 无此行（runtime 经 `CLAUDE.local.md` 指针接入）。三字段中的项目名与定位在此，提交前校验命令属 runtime 工程约定节。
- **`sdd/runtime/claude.md` 骨架**（治理运行时唯一内容源，章节顺序固定，与 `CLAUDE.md` 同批最后由主会话写）：标题 `# <项目名> · SDD 协作规则` → 溯源行（`> sdd@star-plugins <版本> · edition：full`）→ 需求层级（三层 Initiative/Proposal/Task）→ 会话必读（CONSTITUTION → INDEX → INITIATIVE，冷启动摘要含构想池概览）→ 命令一览（表：命令 × 用途，表下注明：调用即文件名形式 `/sdd-intake` 等）→ 硬规则 → 路径、ID 与工程约定（分区路径、I/P/T/A 发号、日期唯一源 `date +%F`、提交前校验命令或「无」）。硬规则必须含（8 条）：
  - ① INDEX 是状态唯一权威源、INITIATIVE 是构想唯一记录，变更即时同步
  - ② 新想法先分类：维护直接做；需求一律经 `/sdd-intake` 受理
  - ③ 定稿后需求变更留痕升版，禁静默覆盖
  - ④ 被否备选记入提案否决记录；已完结决策的推翻替换记入 `amendments/amend.md`，禁删漏记
  - ⑤ 写改 sdd 文档后运行 mdLint，零 error 方可回报
  - ⑥ 归档后 sdd 全区只读
  - ⑦ 命令文件（`.claude/commands/*.md`）新增或删除后必须同步增删 `.opencode/commands/` 同名存根，`description` 变更须同步存根描述行，正文永不复制
  - ⑧ 治理文档只在主干演进：代码在 `dev/<标题 slug>` 分支开发、`test/<标题 slug>` 分支验收（split 切 dev、全任务 done 合并 test、accept 发布主干），治理文档只在主干由主会话写；提交信息 title 与 body 不含治理 ID，需要引用时按 trailer 惯例置 footer（Task 完成 `Closes: T-XXX`、验收修复 `Fixes: T-XXX`、仅关联引用 `Refs: T-XXX`）；footer 区可并存项目自有 trailer，也可有多个 trailer；standalone 形态 footer 句整体替换为「提交信息不含治理 ID、治理引用与 sdd 字样（项目仓无痕化），内层治理仓提交不受此限」

- **INDEX 结构**：项目状态行 → 发号计数器（next-P/next-T）→ 提案总览单表（ID/标题/规模（S≤5 任务 / M 6-20 / L>20，未预判留空）/状态/任务进度 done/total（如 3/8）/规格版本/更新日期/备注；不设来源列，组归属由 frontmatter `source` 推导）。

- **语言与措辞**：治理文档正文中文；文件名英文 kebab-case（冷启动必读文档大写）；章程规则一律「必须/禁止/若…则…」可执行措辞。对话与推理用中文（此句不写入任何治理文档）。

## 六、验证与回报

1. **失败处置（总则）**：任何验证失败，修复后必须重跑对应**全量**验证（mdLint 失败即对全部生成文件重跑，非仅复验出错项），全部通过方可进入下一步；禁止跳过任何验证步骤（明示豁免者除外）、禁止带病提交、禁止以「已修过」为由免检。
2. 文件齐全、结构正确、必填项已填（inline 31 文件：19 治理文件 + 1 治理工具 + 1 版本标记 + 11 OpenCode 适配文件；standalone 32 = 再 +`CLAUDE.local.md`）；`sdd/VERSION` 内容与本提示词顶部版本 + `+full` 一致；`.git/hooks/pre-commit` 已生成且可执行（不入库、不占清单，初始化提交经其实测；standalone 另有内层 `sdd/.git/hooks/pre-commit` 与 `.git/info/exclude` 六行）；
3. 对全部生成文件运行 `sh sdd/tools/mdlint.sh sdd/ CLAUDE.md .claude/commands/ AGENTS.md .opencode/commands/`（standalone 下追加 `CLAUDE.local.md`），零 error；
4. ID/状态机/矩阵在 CONSTITUTION、INDEX、INITIATIVE、模板、7 命令间交叉一致；
5. `git check-ignore -v .claude/settings.local.json .opencode/tmp.local.json`（后一文件名任取一个不存在的即可）→ 均命中；`git check-ignore .opencode/opencode.json` → inline 无输出（未被忽略）/ standalone 命中（排除清单生效）；
6. `opencode debug config` → 7 个 sdd 命令全部被发现（description 与 §5 命令规格表逐字一致、模板正确）且含 `"lsp": true`（opencode 未安装时跳过本条并在回报注明；其运行副产物被 `.opencode/.gitignore` 自忽略，不影响提交）；
7. git 提交均显式列举文件路径添加、禁用 `git add -A` 与 `git add .`：inline 两笔，第一笔仅 21 清单文件（19 治理 + 工具 + VERSION，含 runtime ×2），消息固定 `chore: 初始化 SDD 需求治理体系（19 治理文件 + mdlint 工具 + 版本标记）`；第二笔仅 10 适配文件（`AGENTS.md` + `.gitignore` + `opencode.json` + 存根 ×7），消息固定 `chore: 适配 OpenCode（命令存根 @ 引用 + .opencode 共享配置）`。standalone 两仓各一笔：项目仓仅 `CLAUDE.md` + `AGENTS.md`，message 固定 `docs: 项目协作入口`（中性，无 sdd 字样）；内仓 `git -C sdd` 提交 `sdd/` 全部，消息同 inline 第一笔。除清单文件与 hook 外禁止创建任何其他文件（评审/提示词等用户文档不入库）；
8. 冒烟演练默认**不执行**，初始化完成后待命 `/sdd-intake` 接首个真实需求；后续冒烟（用户在 opencode TUI 手动）：输入 `/` 查看命令补全、执行任一只读命令（如 `/sdd-board`）、问「本项目会话必读是什么」应答 CONSTITUTION → INDEX → INITIATIVE（验证 runtime 注入链路：inline 为 `CLAUDE.md` @ 引用，standalone 为 `CLAUDE.local.md`）；
9. 最终回报：文件清单 + commit hash（inline 两个 / standalone 两仓各一）+ mdLint 结论 + 各项验证结论 + 初始化耗时（总时长，人类可读格式）+ hook 安装结论（含 standalone 内层 hook）+ 治理形态 + 模式（全新 / 升级）与版本去向（升级回报项见 §8）。

## 七、OpenCode 适配设计（生成与验证的唯一规格源）

适配是初始化的自然组成部分（生成见 §2 第三步，提交与验证见 §2 第四步与 §6）；本节仅承载逐字规格与设计依据。

### 核心原则

- **唯一源（OpenCode 侧零内容创造）**：治理规则唯一源 = `sdd/runtime/claude.md`（经 `opencode.json` 的 `instructions` 加载），OpenCode 侧新增内容仅 `sdd/runtime/opencode.md` 补充壳；命令唯一源 = `.claude/commands/*.md`，存根仅作引用壳。禁止复制正文（双源漂移）、禁止软链（跨平台克隆失效）、禁止在 OpenCode 侧另建平行规则或命令内容
- **`AGENTS.md` 为项目骨架**：公开面文件（项目名、定位），零 sdd 痕迹，两形态同文；不再是治理入口（治理规则经 `instructions` 直达）
- **本地化约定**：仅 `*.local.*` 后缀文件为机器本地；忽略机制按治理形态，inline 经 `.gitignore`、standalone 经 `.git/info/exclude`（排除清单见 §2 第三步 standalone 分支）
- **零侵入**：治理文件（`sdd/`、`.claude/commands/`）零改动

### 生成文件逐字规格

`.gitignore`（仅 inline 形态；追加，不存在则新建，已含则跳过；standalone 形态一字不动）：

```
# 本地文件不入库
*.local.*
.worktree/
```

注意：`.opencode/opencode.json` inline 形态受 git 管理，禁止加入忽略清单；standalone 形态经排除清单忽略。

`AGENTS.md`（项目根，两形态同文；`<项目名>`、`<项目定位一句话>` 为 §2 必填项）：

```
# <项目名> · OpenCode 入口

<项目定位一句话>
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

`.opencode/commands/<名称>.md` 存根（与 `.claude/commands/*.md` 一一对应）：description 从对应源文件 frontmatter 原样复制（值以 §5 命令规格表为唯一来源），正文仅 `@` 引用与参数行，格式如下（其余 6 个同构）：

```markdown
---
description: Capture a new requirement and shape it into initiatives or proposals
---

@.claude/commands/sdd-intake.md

用户参数：$ARGUMENTS
```

要点：自带「用户参数：`$ARGUMENTS`」行，无论 OpenCode 内部替换与注入孰先孰后，参数必达；源文件 frontmatter 随 `@` 注入出现为文本属预期噪音；存根中的描述重复仅作 TUI 显示，漂移无功能影响。

### 机制依据与禁改道清单

机制依据（核实日期：2026-08，OpenCode 官方文档与源码；版本演进后如遇行为不符须复核，勿照单全收）：

- `.opencode/` 内主配置仅认 `opencode.json` / `opencode.jsonc`；缺失文件安全降级为空配置
- 根 `AGENTS.md` 存在时 OpenCode 不再回退读 `CLAUDE.md`；2.0.0 起 `AGENTS.md` 为项目骨架，治理规则改经 `instructions` 加载 `sdd/runtime/` 两文件，不依赖 `CLAUDE.md`
- `instructions` 为 E2E 实证项：路径若相对配置目录解析则如上（`../sdd/…`），若相对项目根则去 `../` 前缀；接不上时回退 = 存根命令自带前置检查（读 CONSTITUTION → INDEX）保证流程可用，治理规则经命令文件内引用补达
- standalone 形态下贡献者 clone 无 `sdd/`，`instructions` 指向缺失文件须安全降级（不报错、不阻塞），属预期，E2E 核查
- 命令格式（frontmatter `description` + `$ARGUMENTS`）与 Claude Code 同构
- `"lsp": true` 按需启动全部内置 LSP 服务器，无源码零开销；首次运行自建 `.opencode/.gitignore`（自忽略）并后台安装 `@opencode-ai/plugin`，不出现在 `git status`，属预期

已否决、禁止执行时改道：`OPENCODE_CONFIG` 环境变量加载本地配置（换启动方式即失效）；共享根 `opencode.json`（配置统一收口 `.opencode/`）；`AGENTS.md` 纯提示词分发命令（无原生命令与补全，被存根方案取代）；迁移 `.claude/skills/` 双原生（需重构既有命令结构，超出适配范畴）；`AGENTS.md` 以 `@` 引用 `CLAUDE.md` 补回治理规则（2.0.0 起 `CLAUDE.md` 为项目骨架，无治理内容可补）。

## 八、升级模式：既有安装的就地合并

> 触发判定、校准分类、验证与回报以本节为唯一规格源；升级复用初始化的四步骨架与全量验证，不新增命令。

### 触发判定

前置检查的冲突检测命中项构成**全套签名文件**时，经用户确认转升级模式；任一缺失则照旧停止并报告冲突清单：**部分存在不触发升级**，禁止自行补齐缺失项后覆盖。签名集（以下存在性检查全部命中才转升级）：

- `sdd/CONSTITUTION.md`、`sdd/INDEX.md`、`sdd/INITIATIVE.md`、`sdd/amendments/amend.md`
- `sdd/templates/` 下 proposal / spec / design / task ×4 全在
- `sdd/tools/mdlint.sh`、`sdd/archive/README.md`
- `CLAUDE.md`、`.claude/commands/` 下 7 命令全在
- `AGENTS.md`、`.opencode/opencode.json`、`.opencode/commands/` 下 7 存根全在

`.gitignore` 与 `.git/hooks/pre-commit` 不入签名集（补装语义：缺失即补，存在即覆盖 / 补行）。典型场景为环境重建：项目于新主机 clone 后 `.git/hooks/pre-commit` 必然缺失，全套签名文件在库即命中本模式，重装即补。命中后向用户明示「检测到既有安装（版本见 `sdd/VERSION`），转入升级模式」并等待确认；确认后校验 git 索引干净（`git diff --cached --quiet`），有预置暂存则停止，请用户先处理（防混入升级提交）。

**形态判定**：`sdd/` 为独立 git 仓（存在 `sdd/.git`）即 standalone 形态，否则 inline；既有低版本安装（无 `sdd/runtime/`）一律视为 inline，升级时先执行「`CLAUDE.md` 重写与回读规则」节的 2.0.0 一次性迁移再校准。standalone 安装预检双仓索引干净（外层与 `git -C sdd diff --cached --quiet` 均过）。升级永远维持当前形态，不提供形态切换。

### 校准分类（三档）

| 档 | 文件 | 处置 |
|---|---|---|
| 静默覆盖 | `sdd/tools/mdlint.sh`、`.git/hooks/pre-commit`（重装并加可执行位；standalone 另装内层 `sdd/.git/hooks/pre-commit` 变体）、`sdd/templates/` ×4、`.claude/commands/` ×7、`.opencode/opencode.json`、`.opencode/commands/` ×7 | 按规格纯复制覆盖 |
| 保护性写入 | `.gitignore`（inline）、`AGENTS.md`、`sdd/CONSTITUTION.md`、`sdd/runtime/claude.md` | 规格重生成 + 项目内容回读回填（见下） |
| 活文档仲裁 | `sdd/runtime/claude.md`（`CLAUDE.md` 公开骨架一并按规格重写） | 骨架节重写 + 项目内容保留（见下） |
| 禁触 | `sdd/INDEX.md`、`sdd/INITIATIVE.md`、`sdd/amendments/amend.md` 内容；`sdd/specs/`、`sdd/exploring/`、`sdd/journal.md`、`sdd/archive/` 全部 | 一律不改（骨架仅按本节「骨架差异比对」锚点只读比对） |

保护性写入细则：`.gitignore`（仅 inline）三行逐行补缺，即 `# 本地文件不入库`、`*.local.*`、`.worktree/`，已有行不动、项目自有行禁删禁改、文件不存在才新建，严禁整文件重写（standalone 形态不写 `.gitignore`，改维护 `.git/info/exclude` 六行排除清单）；`AGENTS.md` 按 §7 逐字重生成 + 项目名与定位回填；`sdd/CONSTITUTION.md` 按 §4 逐字重生成 + 项目名回填 + 末尾生效日期保留原文件原值（识别原文件末尾 `YYYY-MM-DD` 日期行；回读失败以当日 `date +%F` 重置并在回报注明）；`sdd/runtime/claude.md` 按 §5 runtime 骨架重生成。

### 必填项回读（升级模式不询问）

项目名 ← `CLAUDE.md` 首行标题（备选 `AGENTS.md` 标题）；项目定位一句话 ← `CLAUDE.md` 首段定位句；提交前校验命令 ← `sdd/runtime/claude.md`「路径、ID 与工程约定」节（2.0.0 前旧结构 ← 旧 `CLAUDE.md` 同名节）。三项均回读不到时询问用户（升级模式唯一询问点），拒答按默认值生成并在回报注明。

### 执行顺序与幂等

1. 起始时间戳（`date +%s`）→ 触发判定 → 必填项回读
2. 两路并行校准（见下）→ 主会话最后重写 `sdd/runtime/claude.md` 与 `CLAUDE.md`（同初始化的串行屏障）→ 写 `sdd/VERSION`（内容 = 本提示词顶部版本 + `+full`；经插件调用时取插件清单 `version` + `+full`）
3. 全量验证（§6 全量项：mdLint 零 error + 交叉一致 + check-ignore + opencode debug config）→ 提交（见下）→ 回报（见下）

**幂等**：校准按「现行规格 vs 磁盘现状」状态化执行，不依赖版本值分支；升级可安全重跑，中断恢复 = 直接重跑（中断不会造成签名集缺损，重跑仍命中升级模式）。

### `CLAUDE.md` 重写与回读规则

- 按节标题锚点识别骨架（2.0.0 起骨架在 `sdd/runtime/claude.md`：需求层级 / 会话必读 / 命令一览 / 硬规则 / 路径、ID 与工程约定 + 溯源行；`CLAUDE.md` 为公开项目骨架），以 §5 对应骨架规格重写。
- 命令一览表与硬规则属单源复制辖区：项目改写过也**以规格为准重写**，被覆盖改动逐项列入回报（用户可经 git 历史回退）。
- 项目填写三字段（项目名 / 定位一句话 / 提交前校验命令）回读保留；识别不到骨架锚点的小节视为项目自有内容，**原样保留**并在回报列出。
- **2.0.0 一次性迁移（inline 旧安装，仅此一次）**：识别旧结构（`CLAUDE.md` 含骨架六节、无 `sdd/runtime/`）→ 回读三字段与项目自有增补节 → 生成 `sdd/runtime/claude.md`（六节的 sdd 部分与溯源行迁入，措辞按现行规格）→ 重写 `CLAUDE.md` 为公开项目骨架（三字段回填、自有增补节原样保留、加 `@sdd/runtime/claude.md` 行）→ `AGENTS.md` 改项目骨架、`opencode.json` 增 `instructions`、新增 `sdd/runtime/opencode.md`（均按 §7 规格）→ 回报列迁移清单（何文件何节迁往何处）。迁移后走常规校准；standalone 安装天然为新结构，无迁移。

### 执行策略（两路并行）

- 治理组：`CONSTITUTION.md` 重生成 + `sdd/runtime/claude.md` 回读材料整理 + `INDEX.md` / `INITIATIVE.md` / `amendments/amend.md` 骨架锚点只读比对，自读本节 + §4 全文 + §5 生成骨架节。
- 机械资产组：命令 ×7、模板 ×4、`mdlint.sh`、hook（含 standalone 内层变体）、OpenCode 适配 ×11 覆盖，自读本节 + §7 全文。
- 主会话自读本节全文（`runtime/claude.md` 仲裁、验证与提交操盘）；不支持 subagents 时按治理组 → 机械资产组 → 主会话串行，步骤不变。

### 提交与回报

- 提交按实际变更文件显式列举、禁用 `git add -A` 与 `git add .`，分两批（同初始化分主题）：第一批 = `CLAUDE.md` + 命令 ×7 + `sdd/CONSTITUTION.md` + `sdd/VERSION`，消息固定 `chore: 升级 SDD 治理体系（机械资产校准 + 活文档仲裁）`；第二批 = `AGENTS.md` + `.gitignore` + `.opencode/opencode.json` + `.opencode/commands/` ×7，消息固定 `chore: 升级 OpenCode 适配资产`。某批零变更 → 跳过并在回报注明（commit hash 为 0 / 1 / 2 个）。standalone 形态：治理资产变更 `git -C sdd` 提交（消息同第一批固定文案）；项目仓仅公开骨架（`CLAUDE.md` / `AGENTS.md`）有变更时一笔中性 message 固定 `docs: 更新项目协作入口`，无变更则项目仓零提交。
- 回报项：治理形态 + 模式与版本去向（`X → Y`，或「旧版安装 → Y」）+ 覆盖清单 + 仲裁结果（保留的项目字段与自有增补清单、被覆盖改动清单）+ 骨架差异报告（无差异则注明）+ 迁移清单（2.0.0 一次性迁移）+ 跳过批次 + commit hash（standalone 为两仓各自）+ mdLint 结论 + 各项验证结论 + 升级耗时（总时长，人类可读格式）+ hook 重装结论（含 standalone 内层 hook）。

### 骨架差异比对与报告

只比锚点不比全文。INDEX 比 `next-P` / `next-T` 计数器标签在位 + 提案总览表表头列集合与现行规格一致；INITIATIVE 比 `next-I` 标签在位 + 条目格式引言行在位；`amendments/amend.md` 比 `next-A` 标签在位 + 条目格式指引行在位。计数器值、数据行、条目内容一律不参与比对（防活跃项目误报）。报告格式固定：每文件一段 = 文件名 + 差异锚点清单 + 「人工迁移建议：对照 §5 对应骨架节」+ 明示「未自动修改」。

### 边界处置

- **部分安装**：照旧冲突停止并列缺失项，禁止补齐后覆盖。
- **`sdd/VERSION` 缺失或损坏**（内容不匹配 `^[0-9]+\.[0-9]+\.[0-9]+\+(slim|full)$`；裸版本为 edition 后缀引入前的旧版，视为 full）：照常升级（校准不依赖版本值），回报注明「旧版安装」或「版本标记异常，疑似损坏 / 篡改」。
- **opencode 未安装**：验证对应项跳过并在回报注明（同初始化条款，禁止自动安装）。
- **worktree 在途**：升级只写主干路径，与 worktree 内代码零交集；回报列 `ls .worktree/` 在途提案作提示；hook 重装落 `.git/hooks/`（共享 git dir），对全部 worktree 即时生效属预期。
- **并发改写**：不对 `sdd/runtime/claude.md` 加锁；提交前全量验证 + 幂等重跑兜底。
