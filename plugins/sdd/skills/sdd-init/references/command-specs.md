# 命令、模板与语言规范

> 生成 7 命令、模板、CLAUDE.md、INDEX、INITIATIVE 时以本文件为唯一规格源。

- 7 命令统一 `sdd-` 前缀；每命令正文必含：角色、前置检查、动作序列、完成回报格式，正文中文；**frontmatter description 英文**；均支持 `$ARGUMENTS`（约定见下表）；写 sdd 文档的命令（intake/finalize/split/start/accept/archive）在完成回报前必须运行 mdLint 且零 error；命令与状态的对应关系以宪法「状态转换 × 文档同步矩阵」为唯一来源；**description 与参数约定以本文件命令规格表为唯一来源**，CLAUDE.md 命令一览表、各命令 frontmatter、.opencode 存根描述一律由此复制，禁止另编。

  | 命令 | description（英文，frontmatter 原样） | 触发时机 | $ARGUMENTS 约定 | 动作依据（矩阵） |
  |---|---|---|---|---|
  | sdd-intake | Capture a new requirement and shape it into initiatives or proposals | 新需求受理（含插单与回看拆解） | 可选：需求描述 | 先跑维护/需求分类三问，判维护直接做并结束；再按单/多交付物分流：直接发 P 或立 I 拆解 |
  | sdd-finalize | Finalize an exploring proposal into a spec | 探索定稿 | 可选：P-XXX | exploring→specified 行；执行前过软门自查 |
  | sdd-split | Split a finalized proposal into design tasks | 定稿后拆任务 | 必填：P-XXX | specified→implementing 行 |
  | sdd-start | Implement tasks from the design task list | 实现推进（默认单 Agent 开发，可派发多 Agent 并行开发） | 可选：P-XXX（批量推进该提案全部未完成 T）/ T-XXX（仅推进该 Task，并行派发用）；缺省推进下一个 todo T | 接 P-XXX：从首个未完成 T 起顺序推进（doing → 实现 → 回填 → done）至全 done；接 T-XXX：仅该 Task；缺省：下一个 todo T；任一 Task 状态变化行；全任务 done → 执行 verifying 转换（见矩阵：合并 dev → test、删 worktree 与 dev 分支、交付 hash、列 AC 清单）+ 提示人工测试（主工作区检出 test）；测试通过后 /sdd-accept |
  | sdd-accept | Verify acceptance criteria and mark the proposal accepted | 全任务 done 后验收 | 必填：P-XXX | verifying→accepted 行；完成回报固定建议「回看需求组拆下一个」 |
  | sdd-board | Show initiative and proposal status overview | 查看状态（只读） | 可选：I-XXX / P-XXX | 无矩阵行：读 INDEX + INITIATIVE + design 任务表输出摘要（含需求组聚合），不改任何文档 |
  | sdd-archive | Archive accepted proposals into the archive area | 归档 | 可选：P-XXX（缺省全部 accepted） | 归档行 |

- 模板四件套（sdd/templates/ 下固定文件，源 = 本技能 `templates/` 目录；P-XXX/T-XXX/I-XXX 为占位，建文件时替换为实际号；`source` 行仅提案源自 I-XXX 时生成，独立提案删除此行），**骨架即规格**，见下。**设计是实现的副产品，不是事前作文**：定稿后建骨架、每 Task 完成回填、verifying 时补全置 finalized。

  **proposal.md**

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

  **spec.md**

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

  **design.md**（方案概述引 A-ID）

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

  **task.md**（Task 条目格式定义，非任务文件）

  - 表行字段顺序：`T-XXX | 标题 | 状态 | 分组 | 备注`
  - 状态合法转换：`todo → doing → blocked → todo / done`；`done`、`dropped` 为终态；doing 即锁定，禁重复派发
  - 详情小节格式：说明（依据规格/设计节选）→ 实现记录（完成时回填：做法 + 证据）；完成判据 = 对照 spec 相关 AC 条目，验收核对统一在 /sdd-accept 进行（验收项不属于 Task）
  - 子智能体回报格式：做了什么 / 验收逐条结论 / 问题与规格偏差（走 R5 上报主会话）

- **INITIATIVE.md 生成骨架**（构想池，构想唯一记录）：

  ```markdown
  # 构想池

  > 计数器：next-I: 001
  > 条目格式见 CONSTITUTION「构想池」节；raw 便签无号，梳理成熟原地升格为 I。

  （暂无活跃构想）
  ```

- **amendments/amend.md 生成骨架**（修正登记簿 + A 计数器）：

  ```markdown
  # 修正案（Amendments）

  > 计数器：next-A: 001
  > 只录已完结提案实现后被推翻或替换的决策反转，追加式录入；条目格式与替换流程见 CONSTITUTION「修正机制」节。

  （暂无修正案）
  ```

- **CLAUDE.md 骨架**（章节顺序固定，最后写）：标题 `# <项目名>` + 项目定位一句话（首行）→ 需求层级（三层 Initiative/Proposal/Task）→ 会话必读（CONSTITUTION → INDEX → INITIATIVE，冷启动摘要含构想池概览）→ 命令一览（表：命令 × 用途，表下注明：调用即文件名形式 `/sdd-intake` 等）→ 硬规则 → 路径、ID 与工程约定（分区路径、I/P/T/A 发号、日期唯一源 `date +%F`、提交前校验命令或「无」）。硬规则必须含（8 条）：
  - ① INDEX 是状态唯一权威源、INITIATIVE 是构想唯一记录，变更即时同步
  - ② 新想法先分类：维护直接做；需求一律经 `/sdd-intake` 受理
  - ③ 定稿后需求变更留痕升版，禁静默覆盖
  - ④ 被否备选记入提案否决记录；已完结决策的推翻替换记入 `amendments/amend.md`，禁删漏记
  - ⑤ 写改 sdd 文档后运行 mdLint，零 error 方可回报
  - ⑥ 归档后 sdd 全区只读
  - ⑦ 命令文件（`.claude/commands/*.md`）新增或删除后必须同步增删 `.opencode/commands/` 同名存根，`description` 变更须同步存根描述行，正文永不复制
  - ⑧ 治理文档只在主干演进：代码在 `dev/<标题 slug>` 分支开发、`test/<标题 slug>` 分支验收（split 切 dev、全任务 done 合并 test、accept 发布主干），治理文档只在主干由主会话写；提交信息 title 与 body 不含治理 ID，需要引用时按 trailer 惯例置 footer（如 `Fixes: T-XXX`）

- **INDEX 结构**：项目状态行 → 发号计数器（next-P/next-T）→ 提案总览单表（ID/标题/规模（S≤5 任务 / M 6-20 / L>20，未预判留空）/状态/任务进度 done/total（如 3/8）/规格版本/更新日期/备注；不设来源列，组归属由 frontmatter `source` 推导）。

- **语言与措辞**：治理文档正文中文；文件名英文 kebab-case（冷启动必读文档大写）；章程规则一律「必须/禁止/若…则…」可执行措辞。对话与推理用中文（此句不写入任何治理文档）。
