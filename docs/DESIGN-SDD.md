# SDD 需求流程设计

> 2026-09-01 定稿。本文件是 SDD 体系的**设计总纲**：记录需求流程的全部设计决策，是插件规格（`SKILL.md` / `references/` / `templates/`）的唯一演进依据。

## 一、文档层级

- 本仓是 SDD 体系的唯一发展与规格权威。
- 文档层级：`DESIGN-SDD.md`（设计总纲，本文件）→ 插件规格。设计变更先修订本文件，再落到插件规格。

## 二、设计目标

1. 轻量受理：念头先进池子，成熟才正式建档；
2. 粒度清晰：构想与工程分层，I 拆 P、P 拆 T，各层职责单一；
3. 探索重行为：探索到收敛才有资格定稿，产物不流于模板填充；
4. 多探索有序：构想与探索分层管理，冷启动与看板提供全局视图。

## 三、命名体系

| 类别 | 定案 |
|---|---|
| 命令（6 个） | `/sdd-intake` · `/sdd-start` · `/sdd-board` · `/sdd-accept` · `/sdd-archive` · `/sdd-config` |
| 治理文档 | `CONSTITUTION.md`（宪法，根本法）· `INITIATIVE.md`（构想池）· `amendments/amend.md`（修正登记簿）· `INDEX.md` · `exploring/` · `specs/` · `archive/` · `templates/` · `tools/` · `journal.md` |
| ID 前缀 | `I-XXX`（Initiative）· `P-XXX`（Proposal）· `T-XXX`（Task）· `A-XXX`（Amendment） |
| 状态 | Proposal：`exploring` / `implementing` / `verifying` / `accepted` / `on-hold` / `rejected`；`done` 唯一属于 Task；design：`draft → finalized` |

## 四、大写规则与文件结构

**全大写 = 冷启动必读链**。大写是制度而非风格：必读文档大写，其余一律小写并落入二级目录。`ls sdd/` 的视觉即治理：三个大写文件是必读三件套，其余全是小写工作目录。

```
sdd/
├── CONSTITUTION.md   ← 必读三件套（一级 · 大写）
├── INDEX.md          ← 状态唯一权威源 + 发号计数器
├── INITIATIVE.md     ← 构想池（总纲层）
├── amendments/       ← 修正登记簿 amend.md（二级 · 小写）
├── exploring/        ← journal.md（探索档案）· P-XXX.md 底稿（运行态）
├── specs/            ← P-XXX/spec.md（稳定区）
├── templates/        ← 模板
├── tools/            ← mdlint.sh
└── archive/          ← 归档区
```

`amendments/amend.md` 为修正登记簿：条目追加式录入，只录**已完结提案（accepted 及之后）**实现后被推翻或替换的决策反转；被替换条目原位标 superseded，反转链在簿内纵览。

## 五、三层实体

| 层 | 实体 | 职责 |
|---|---|---|
| 构想层 | `I-XXX`（Initiative，总纲） | 承载模糊需求的产品层澄清与路线图；不进状态机、无流程 |
| 提案层 | `P-XXX`（Proposal） | 真正的 SDD 开发循环从这里开始（exploring → … → accepted） |
| 任务层 | `T-XXX`（Task） | design 任务清单内 |

- **I 是总纲**：一个模糊需求经澄清后产出**一个** I；条目内保留原始念头原文（用户原话原则在产品层的对应）、产品层澄清结论与路线图。兄弟血缘、组块、同源行、父指针一概不需要，一个池条目就是一个 I。
- **raw 便签无号**：未成熟念头只是 `INITIATIVE.md` 里的无编号条目，随时可删除；梳理成熟才授予 I 号（计数器位于 `INITIATIVE.md` 顶部，永不复用）。
- **归属反向指针**：P 的 frontmatter 记 `source: I-XXX`；`INITIATIVE.md` 不记录 P 指向（组归属由 frontmatter 推导，避免双重记账）。直接发号的 P 无 source，即「无 source = 独立需求」。
- **跨组依赖落在 P 层**：记录于 P 规格的「依赖与关联」，工程关切归工程层。
- 拆分动作仍是两级：I 拆 P（intake 层）、P 拆 T（design 层），不跨层。

## 六、流程模型（两路）

```
新需求（含插单）或文档材料（一至多份）→ /sdd-intake
  ├─ 维护/需求分类三问 → 判维护：直接做并回报，intake 即结束
  ├─ 听需求 → 第一轮产品澄清 → 单/多交付物判定（对话产出，非门槛，可修正）
  ├─ 单交付物（XS/S/M 皆可）→ 直接发 P-XXX（无 source，不进池）→ 既有状态机
  └─ 多交付物/模糊大需求 → INITIATIVE.md 立 I 条目（原文保留）→ 继续拆解
       → 发 P-XXX（source: I-XXX，用户确认）→ 既有状态机
误入池出口：拆解后发现实为单交付物 → 关闭 I 条目，直接发 P（无 source）
```

- **单交付物判据 = 三问测试**（见第七节）：XS/S/M 只要装得进一个可独立验收的 Proposal 就直接发号。**I 只为「结构」而生**：需要产品层结构（多里程碑、多子产品、路线图）时 I 才有意义，单块交付的需求里 I 只是 P 的影子。
- 两路各付一种代价，已确认为更优解：两路付「每次判断」的成本，换取小需求不被 I/P 重复登记。
- **受理一站式（3.0.0）**：探索、定稿与任务拆分并入 intake 一站完成——受理即建底稿与 spec / design 骨架，探索填实后软门自查，过门落位（切 `dev/<slug>` worktree 进 implementing）；可重入直至无疑虑，finalize / split 命令撤除。
- **文档受理**：`/sdd-intake` 的 `$ARGUMENTS` 可为一至多份文档（路径或粘贴；体裁不透明，可含测试套件；不建模材料来源）。流程：读材料 → 拆解定界（立 I 拆 P 同两路；言语行为分辨；存量对账按需触发且只对当前仓库，取证治理账优先、代码与 git 历史兜底）→ 拆解映射确认（材料每个部分显式去向，判据不能少、不能多）→ 批量落位（全部 P 以 exploring 为起点，含糊由探索自然吸收）。材料严格消费：映射确认完毕即无用，不冻结、不收编、不入库，删留归用户；I 条目记一行产物统计（只记库内实体）；未覆盖与暂缓默认落构想池；底稿原始叙述存该提案范围内材料原文逐字。逐条规则见命令规格「文档受理」条款（2.7.0）。

## 七、两个判据测试

### 三问测试（单/多交付物）

| # | 检验问题 | 指向直接 P | 指向 INITIATIVE 池 |
|---|---|---|---|
| 1 | AC 可写性：现在就能写出 1-3 条可核对的验收标准吗？ | 能 | 不能，写出来也是空话 |
| 2 | 边界可划性：范围内外现在就能划清，不依赖后续探索？ | 清楚 | 依赖探索才知道切到哪 |
| 3 | 交付物同质性：单一功能块，还是天然含多个异质交付物？ | 同质 | 异质（模块/阶段/子产品，有结构差异） |

≥2 问指向右侧 → 进 INITIATIVE 池；拿不准时兜底一问用户：「想一口气做完，还是先立框架分期做？」同类重复不算异质（「给 10 个字段加校验」是一个 P 的 10 个 Task）。判错可恢复：池内发现单交付物走误入池出口；直接 P 发现要拆则探索产物回填升格，均非事故。

### 维护/需求分类三问

| # | 检验问题 | 需求（立项，XS 起） | 维护（直接做，不立项） |
|---|---|---|---|
| 1 | 行为变化？ | 新能力/改变系统对外行为 | 恢复既定行为或不改变行为 |
| 2 | 方案空间？ | 存在真实选择 | 路径唯一自明 |
| 3 | AC 自明性？ | 完成标准需协商定义 | 标准自明 |

防误判四保险：**默认偏维护**（判不准一律按维护）；**停损升级**（维护中冒出方案选择或范围膨胀 → 当场停、补立项）；**口令优先**（分类仅为建议，用户一句终局）；**amendments 旁路**（维护暴露决策/设计错误 → 走 A-XXX，呼应 R9「跨周期修正禁只改代码」）。例子锚点：改按钮颜色、修 typo、升依赖 = 维护；国际化、暗色主题、OpenAPI 文档 = 需求（XS 级）。

## 八、测试案例

### 案例一：用户登录功能 → P

「为系统添加用户登录功能」，intake 对话：分类三问判为需求（新能力）；第一轮澄清（登录方式、注册、找回）的落点是 P 的 exploring 文件（工程层）；单交付物判定成立，登录是一个可独立验收的功能块，其复杂性全在工程层（session vs JWT、哈希算法、防爆破等选型），产品结构上就是一块。**直接发 P-XXX（无 source）**→ exploring（认证选型在此探索，spec / design 随受理建档，AC 细化 + 边界、任务拆分 注册/会话/安全/找回 一站完成，软门落位）→ start → accept。

教训：**I 与 P 的分界不是需求大小，而是是否需要产品层澄清与路线图，即「大 ≠ 进池」**。

### 案例二：完整账号体系 → I

「做完整的账号体系：个人/企业账号、SSO、组织权限」，产品级构想，需要路线图，`INITIATIVE.md` 立 `I-XXX` 条目（原文保留；路线图：账号 → SSO → 组织权限）→ 逐个拆出 P，登录注册、SSO 集成、组织权限（各标 `source: I-XXX`）→ 各自走状态机 → 全部 accepted 后 I 标完结。

## 九、探索行为规则（R3）

探索质量是行为问题而非结构问题，规则四条：

1. **自顶向下**：先问题空间（目标、用户、场景、约束）→ 再方案空间（架构方向 → 模块划分 → 关键接口），逐层细化；方向未定禁止钻实现细节。
2. **先发散后收敛**：每个关键决策点先列 ≥2 个候选方向（至少 1 个保守或非常规方案，防锚定）；场景覆盖正常流、异常流、边界条件、非功能诉求。
3. **逐层留痕**：细化过程实时写入底稿，而非事后补写，跨会话中断可恢复；用户给出的内容同样落盘。落盘义务贯穿提案全程：过程写底稿（存活至验收或 rejected 终结），结论演进写 spec changelog。
4. **落位软门**（进入 implementing 前自查）：候选方案有倾向与理由、开放问题全部收敛（已解决或显式转为假设记录）；不满足则回报并建议继续探索。软门不设硬性准入清单，避免仪式感转移。

## 十、自治阶梯（判断自动，动作守门）

| 层级 | 事项 |
|---|---|
| 自动执行，做完告知 | 维护/需求分类判断、维护直接做、新想法落池、三问执行、XS 产物极短化、R1 摘要、board 聚合、自动验收（`Acceptance mode` = auto，验证全绿则自动走 accept 链，见 §十九） |
| 判断 + 明示理由，可一句话推翻 | 建议立项、on-hold 排队建议 |
| 永远用户守门 | 发号（P）、授予 I、验收发起（`Acceptance mode` = manual，见 §十九）、停损升级、archive、决策反转入册（A）、写实现代码 |

## 十一、滚动立项、完结联动与插单

- **滚动立项**：「回看需求组拆下一个」随验收收尾回报固定追加，载体按模式分叉，manual 模式在 `/sdd-accept` 完成回报，auto 模式在自动验收回报（验收节点人工确认限 manual，见 §十九）；需求组最后一个 P accepted **不建议归档**，归档是项目尾声的整体动作，由用户主动发起。
- **完结联动**：组内全部 P accepted → I 标完结 → 归档时条目内容并入 `requirements.md`（需求来源章节）后从 `INITIATIVE.md` 移除；丢弃条目同理。`INITIATIVE.md` 常态只保留活跃需求组。
- **插单四条**：
  1. 落池不打断，新想法当场判层：当前 P 范围内走 R5；组内新里程碑追加路线图备注；无关想法入 `INITIATIVE.md` 新条目（raw）。当前 P 永不因新想法自动中断。
  2. 处理时复用三问测试分流。
  3. 排队不经 on-hold：新 P 不立刻做则受理落位后留在 exploring 即为排队；中途搁置置 on-hold（入口限 exploring / implementing，verifying 不设，见 §十四停驻）。
  4. 切换仅三情形：阻塞当前 P、用户明确要求、决策/方案类修正走 `amendments/`。
- **R1 冷启动加读 `INITIATIVE.md`**：摘要含构想池概览（活跃 I 数、待梳理条目、未立项里程碑）；AI 不主动催梳理。
- **`/sdd-board` 聚合**：输出按 `source` 聚合的需求组进度段（如 I-002：P-010 accepted / P-011 implementing / 2 个里程碑未立项）；INDEX 不加列。

## 十二、治理不变式

- 状态机 4 态骨架（旁路 on-hold / rejected）与禁止跳跃
- INDEX 唯一权威源（不加列）
- mdLint 契约与提交兜底（目标项目 `.git/hooks/pre-commit` 拦 error，凡入库必合规，工具无关、不入库）
- 归档四产物结构（仅并入完结条目内容）
- 两级拆分动作（I 拆 P、P 拆 T）
- 原始叙述保留用户原话
- journal 探索档案（追加式）
- 治理文档主干单线

## 十三、执行策略（生成阶段）

- **四路并行**：前置检查与必填项问答完成后，生成阶段按文件组分派 subagents 并行执行。

  | 组 | 生成物 | 自读规格 |
  |---|---|---|
  | ① | CONSTITUTION、INDEX、INITIATIVE、`amendments/amend.md` | constitution-design 全文 + command-specs（两个生成骨架） |
  | ② | 命令 ×6（`.claude/commands/`） | command-specs + constitution-design「状态转换 × 文档同步矩阵」节（定点读取） |
  | ③ | 模板 ×4（纯复制）、`tools/mdlint.sh`（纯复制）、archive/README | 近乎零 |
  | ④ | OpenCode 适配 ×9 | opencode-adapter 全文 |

- **串行屏障**：`sdd/runtime/claude.md` 与 `CLAUDE.md` 最后由主会话写（引用全部生成物）；汇合后必须由主会话执行「验证与回报」全量校验（mdLint 全量重跑 + 交叉一致），通过后按治理形态提交（§十八）。
- **计时回报**：起始时间戳（`date +%s`）记于前置检查起点，收尾取结束时间戳算差值；最终回报含「初始化耗时」，仅报总时长（人类可读格式），不分阶段。
- **一致性来源**：并行不破坏逐字纪律，各组照抄单源规格，交叉一致由全量校验兜底。
- **成本核算**：各组自读规格合计约 9-10k input tokens（串行生成约 6k），差额以美分计，换取生成时长约减半；主会话不读规格、不持有生成文件全文，上下文更省。
- **回退**：组 subagent 回报工具缺失时按宪法规格「工具可用性实证」节处置（调用实证复核、重派一次）；环境不支持 subagents 或重派仍败时按组序串行生成，其余步骤不变。
- **升级模式**：既有安装的就地合并走 sdd-init 升级模式，其执行策略见 §十六。

## 十四、Git 工作流（分支开发，主干发布）

- **粒度与时机**：分支以 P-XXX 为单位、双分支制，`dev/<标题英文 slug>`（开发）与 `test/<标题英文 slug>`（验收）。
  - 受理落位创建（exploring → implementing 软门过，可写码起点）：从 main 切出 `dev/<slug>` 并建 worktree（检出 dev）
  - 全任务 done（verifying）：从当前 main 切出 `test/<slug>`、合并 `dev/<slug>` 入 test（冲突一律在 test 解决），代码进入验收（worktree 与 dev 分支保留，删除时点后移至 accept，见停驻）
  - 并行分提案级与任务级两种，均采用派发-回收。提案级并行：多个 P 同时推进，各占 dev / test 分支与 worktree 隔离，由推进提案任务清单（含验收验证的执行）的 subagent 承载，受验收串行约束（至多一个 P 持有 test，见下）；任务级并行：单个提案内多个 Task 同时实现，多个 subagent 各持单 Task 简报；默认单智能体顺序推进，用户明确要求时切派发-回收
  - 验收结论与治理记录始终由主会话定夺
- **载体统一 worktree**：`git worktree add .worktree/<标题英文 slug> -b dev/<标题英文 slug>` 创建（分支 + 工作区一步，目录名与分支名同源）；`.worktree/` 入 `.gitignore`；主工作区常驻主干；验收测试在主工作区检出 `test/<slug>` 进行（主工作区即用户可运行环境）；单/多 Agent 同一机制，无例外。
- **test 串行与主干冻结**：全流程同时至多一个 P 持有 `test/<slug>`，test 恒从当前最新 main 切出（提案间并行自 implementing 层展开，验收串行）；验收位被占用时，全任务 done 的 P 留在 implementing 等待（任务表保持全 done，worktree 与 dev 分支保留），待在途 test accept 后再执行 verifying 转换。验收期（test 切出至 accept）内 main 代码不前进（治理文档主干直写照旧）：一切修复（无论缺陷源自哪个 P 的范围，含不进 Proposal 的维护性修复）都落在当前 `test/<slug>`，随本 P accept 一并进 main；验收期外维护仍直接落 main。验收位空闲保证切出时 main 已含全部在先成果，验收期冻结保证 accept 合并恒无冲突。
- **治理文档主干单线**：sdd/ 全部治理文档只在主干由主会话写；分支只承载实现代码。git 拓扑映射治理架构：代码层并行（分支），治理层串行（主干）。会话工作目录不设限，以路径锁定「什么写在哪」：治理文档写主工作区，代码写 worktree；test / dev 检出中的 sdd/ 一律只读，治理写入回主工作区 main。
- **提交**：
  - 治理文档由状态转换命令收尾自动提交主干（信息现场自拟，遵循脱敏与治理引用约定；落仓按治理形态，见 §十八）
  - dev 分支代码提交以 Task 为界：单个提交不混多 Task 改动，Task 完成即提交、一 Task 可多提交；test 分支的修复提交随验收产生
  - 代码合入主干发生在全任务 done 的 verifying 转换（合并 dev → test，accept 发布 test → main），accept 不再合并代码；交付 hash（dev → test 合并）记入 `design.md`
  - 代码提交前须通过项目提交前校验（lint、format、测试等，以项目工程约定为准）；push 永远手动
- **tag**：accept 收尾（治理提交之后）打 annotated tag，版本格式于 init 询问定型并登记于 runtime 工程约定节（选型建议：交付型惯用 CalVer，库 / 产品惯用 SemVer），CalVer（`YYYY.M.D` 验收日，同日多验收追加当日序号）或 SemVer（`vX.Y.Z`，级别可于需求对话中议定并随提案记录，用户可修正；对话期不议的由 accept 自上次 tag 按本次变化推导成号）；信息取本次 CHANGELOG 条目首行（遵循脱敏约束）。tag = 发布门槛：主干可短暂承载 verifying 代码，打 tag 才是发布标记。
- **CHANGELOG**：项目根公开文件，格式以 Keep a Changelog 为基准，不设常驻 `[Unreleased]` 节；实现期零写入，显著变化由 design 任务清单承载
  - accept 时单次写入成文，条目两路：对照 spec 与任务清单识别用户可感知变化按六类归类产出条目；自上次 tag 扫描 git log，将未收录的提交按六类归类补入条目，典型为提案外的维护修复落「修复」类
  - 条目用户语言 `-` 列表，不含治理 ID 与治理词汇，与治理形态无关
  - 版本取本次 tag，节标题按版本格式：SemVer 为 `[版本] - 验收日`，CalVer 版本即验收日、节标题仅 `[版本]`（同日多验收追加当日序号）
  - SemVer 级别可于需求对话中议定并随提案记录（用户可修正），对话期不议的由 accept 按本次变化推导成号
  - 尾部链接区每版本一条 diff 对比链接（自项目远程推导，无远程省略）
  - 守门：随 accept 回报展示，用户可改；落仓 inline 随治理提交，standalone 外层公开文件随中性 message；辖区入外层 hook
  - tag 联动：message 取本次条目首行
- **验收清单表格**：全任务 done 时主会话列出（五列：AC / 验收标准 / 证据 / 验证步骤 / 结论），由 spec「验收标准」表派生（验收标准与 spec 逐字一致），会话输出不落盘
  - 验证步骤按 spec 验证方式分派，已绑定命令的 AC 由登记命令自动验证，执行者条款照旧（简报范围为提案全部任务清单的，由承接该简报的 subagent 执行并回报；简报为单个 Task（任务级并发）或不使用并行推进的，由主会话执行）；`Acceptance mode` = manual 时另有人工验证类（用户操作）
  - 证据逐 AC 指认（验证命令名 · 用例指认 · 输出摘要，人工类记现场结论），指认不出覆盖用例即映射失败，按验证失败处理
  - 失败自动修复重验，重试累计达治理配置 `Verification retry limit`（缺省 3）仍未全绿即停驻：P 置 on-hold（verifying 旁路入，INDEX 备注记失败 AC、轮数与证据缺口），test 分支冻结保留、验收位释放（worktree 与 dev 分支保留，删除时点在 accept），下一排队 P 照常推进并即时回报停驻
  - `Acceptance mode` = auto 时全绿即自动走 accept 动作链（合并 main → CHANGELOG → tag → accepted），无需发起；= manual 时全绿且无人工类 AC 提示用户可验收，由用户发起 /sdd-accept（R7 人工确认，验收节点限 manual）
  - accept 逐条以实际证据核对（结论通过置 ✅），通过后整表追加 journal 作为验收记录；未全过不置 accepted，Task 保持 done，缺陷修复提交以 footer 记 `Fixes: T-XXX` 回链 Task
  - 契约、模式、验收链与兼容的完整设计见 §十九
- **停驻恢复**：由人工发起。INDEX 由 on-hold 置 verifying；原 `test/<slug>` 分支废弃，从最新 main 拉取新验收分支 `test/<slug-N>`（命名避开既有残支），合并 `dev/<slug>` 入新 test（冲突一律在 test 解决）；新验收分支就绪即人工接手，自动化 retry-limit 重试对其失效，后续验收流程与正常验收流程一致。停驻与恢复均即时回报。
- **脱敏与治理引用**：
  - 分支名与 tag message 不含治理 ID 与治理文件名
  - commit message 的 title 与 body 不含治理 ID 与治理文件名；需要引用治理实体时，在 footer 区（body 后空一行、逐行）按 trailer 惯例记，关键词随本提交对实体的作用而定，无引用则不写（Task 完成 → `Closes: T-XXX`，accept 验收提案 → `Closes: P-XXX`，验收阶段修复已完成 Task 的缺陷 → `Fixes: T-XXX`，一 Task 多提交时的非收尾提交等 → `Refs: T-XXX`）；开发过程中的自我修正不属修复语义，随所在 Task 完成提交记；Task 完成只记代码侧提交，主干治理提交不重复记；footer 区可并存项目自有 trailer，也可有多个 trailer
  - 分支名 = `dev/<标题英文 slug>` 与 `test/<标题英文 slug>`，记一行入 `design.md`；治理层实现记录可引用 commit hash（中性回链）
- **终局**：accept 后删除全部 `test/<slug>*` 残支与 `dev/<slug>`、worktree
  - rejected 分环节清理：exploring 未建分支仅删文档；implementing 删 worktree 与 `dev/<slug>`；verifying（含停驻 on-hold）删全部 test 残支与 `dev/<slug>`、worktree；main 零沾染（test → main 合并只发生在 accept 内）
  - on-hold 挂起保留（dev / worktree / test 残支挂起）
  - 主干可短暂承载 verifying 代码，发布门槛 = tag（发布动作不入 SDD 流程）

## 十五、落地阶段

1. **设计**：本文件即设计总纲，交仓库所有者审阅。
2. **规格实现**：已按本设计完成 `plugins/sdd/skills/sdd-init/` 的实现，历次增补按版本列下。

   - **初始实现**：`SKILL.md`、references ×4（constitution-design / command-specs / opencode-adapter / upgrade）、templates ×4（proposal/spec frontmatter 含 `source` 行；INITIATIVE 条目结构入模板）；生成清单 29 文件（含 `INITIATIVE.md` 与版本标记 `sdd/VERSION`），两次提交 19+10；工具 `scripts/` ×2（`mdlint.sh`、`pre-commit.sh`，后者安装为目标项目 `.git/hooks/pre-commit`，提交兜底、不入库，唯一机械强制 hook）；命令规格表与 OpenCode 存根同步。
   - **edition 体系落笔增补**（§十七）：references 增 `slim.md`（slim 生成 / 校准 / 升 full 版逐字规格），`templates/slim/` 增 spec / design ×2，slim 生成清单 18 文件、两次提交 11+7。
   - **治理形态落笔增补（2.0.0）**（§十八）：统一结构重组（runtime ×2、`CLAUDE.md` / `AGENTS.md` 改项目骨架），references ×5 与 PROMPT-SDD 增形态分支，`scripts/` 增 `pre-commit-inner.sh`（内层 hook 变体），生成计数 inline full 31 / standalone 32、slim 20 / 21。
   - **slim 发布标记增补（2.0.1）**：accept 打 annotated tag，发布语义与 full 对齐（§十七）。
   - **CHANGELOG 增补（2.1.0）**：accept 收尾、tag 之前增补项目根 `CHANGELOG.md`（§十四），两 edition 统一，tag 信息取条目首行。
   - **test 串行与主干冻结增补（2.1.1）**：test 串行（验收位唯一）、冲突一律在 test 解决、验收期内 main 代码不前进（§十四）。
   - **公开骨架减负（2.1.2）**：`CLAUDE.md` 与 `AGENTS.md` 项目骨架删去智能体协作声明行（入口自解释，最小公开面）（§十八）。
   - **书写判据加固（2.1.3）**：治理 ID 一律裸写、禁入行内代码并入 mdLint 执法（行内代码内出现即 warning）；文件名与键名组合必包、链接地址裸写（CONSTITUTION「Markdown 书写规范」）。
   - **并行误报防护（2.1.4）**：并行派发能力以实证判定，检索不到不构成不支持证据，降级须实际调用失败并回报注明所测环境（CONSTITUTION「并行开发」）。
   - **登记闸门（2.2.0）**：提交首次涉及未覆盖的工具链工件类时闸门启动，由用户选定工具并登记或扩展校验命令、执行通过后方可提交，凡入库工具链 lint 与 format 必配（CONSTITUTION R10）。
   - **版本格式定型前置（2.4.0）**：init 询问并登记于 runtime 工程约定节，升级回读扩为四字段，存量无记录维持首个 tag 前询问（CONSTITUTION R10 / upgrade）。
   - **验收环节条件化（2.5.0）**：验收清单 AC 标注验证方式，自动验证（简报范围为提案全部任务清单的由承接 subagent 执行，单个 Task 或不使用并行推进由主会话执行），失败自动修复重验，UI 交互类人工操作，纯自动提案全绿直接提示验收，列「人工测试步骤」更名「验证步骤」（CONSTITUTION 矩阵 / R6 / R10）。
   - **自动化验证体系增补（2.6.0）**：AC 契约化（spec 验收标准表格、验证方式绑定命令或人工、auto 模式全绑定方许定稿）、runtime 验证命令区与治理配置区、证据制度（逐 AC 用例指认与摘要留档）、自动验收流水（`Acceptance mode` 门控，auto 全绿自动走 accept 链，`Verification retry limit` 停驻，`/sdd-config` 配置命令与旁通阀）、登记闸门扩展与升级补记（CONSTITUTION R7 / 矩阵 / §十九）。
   - **文档受理增补（2.7.0）**：`/sdd-intake` 输入扩展为一至多份文档（体裁不透明），拆解映射经确认后批量落位（判据不能少、不能多），材料严格消费不收编，I 条目记产物统计，未覆盖落构想池（§六 / 命令规格「文档受理」条款）。
   - **工具可用性实证增补（2.8.0）**：宪法新增「工具可用性实证」正文节（实际调用为唯一判据、自报前须调用实证、复核失败重派一次、反例清单两例），并行开发节实证句并入该节；init 回退判定实证化（§十三 / CONSTITUTION「工具可用性实证」）。
   - **OpenCode 验证面修复（2.8.1）**：opencode v2 起 `debug config` 仅列配置来源、不再呈现命令清单，SKILL / slim / PROMPT 验证改三段式（配置面 `debug config`、存根契约文件核验、命令发现 `opencode run '/sdd-board'` 输出与命令规格一致的看板摘要，sdd-* 同构一通俱通），命令目视归冒烟（opencode-adapter 机制依据更新核实记录）。
   - **standalone 生成计数纠正（2.8.3）**：standalone 不写 `.gitignore`、改生成 `CLAUDE.local.md`，一减一加与 inline 同数（full 33 / slim 22）；2.0.0 起「再 +`CLAUDE.local.md`」口径漏了对应减项，历次 standalone 计数（32 / 21、34 / 23）均多一，现行落点已全部纠正（§十八 / SKILL / slim / PROMPT）。
   - **文档受理消费与发号序完善（2.8.4）**：拆解映射确认明确材料消费一次穷尽、节奏控制在落位之后；多实体发号增依赖拓扑序（被依赖者先号，无依赖者按逻辑递进），发号后永不重排（CONSTITUTION「权威源、ID 与日期」/ 命令规格「文档受理」）。
   - **sdd-split 发号序引称补齐（2.8.5）**：任务表依赖拓扑序排列与 sdd-split 行引称，与 2.8.4 intake 侧对齐（宪法条款已泛化覆盖 T 发号，补执行面可见性）。
   - **slim 提交粒度补齐与码律拆分（2.8.6）**：宪法状态机「代码与 Task 绑定」话题式标签拆为「无 Task 不写码 / 提交以 Task 为界 / 验收期修复回链」三则（限需求治理周期，维护不经本条），slim 补齐提交粒度（E2E 实证 slim + standalone 批量推进后外层仓提交稀疏）；§十七 明示提交粒度为通用纪律。
   - **CHANGELOG 单次写入制（2.8.7）**：废除实现期随 Task 完成记入与 `[Unreleased]` 累积 / 更名两段式，accept 时单次写入成文，条目两路（spec 与任务清单的六类归类条目、提案外维护修复并入）；版本节标题按格式（SemVer 附验收日、CalVer 即日期），SemVer 级别对话期可议定或延迟至 accept 推导（CONSTITUTION「CHANGELOG」/ R10 / 矩阵 / §十四）。
   - **单一 edition 合并（3.0.0）**：slim / full 双轨废止合并为单一 edition——吸收 slim 的受理一站式与 4 态状态观（撤 `specified` 与 finalize / split 命令，定稿并入 intake、软门把关、可重入），保留 full 的分支 / worktree / test 泳道验收流水与治理面全套（INITIATIVE、amendments、archive、模板 ×4）；停驻 on-hold 化（verifying 转换不删 dev / worktree，删除后移至 accept，retry-limit 停驻置 on-hold 释放验收位、流水继续，重入按序号新切 test 合并 dev、不并旧 test）；升级增撤档能力与两支线（VERSION 单值化、旧后缀识别旧结构、遗留 `[Unreleased]` 节首次 accept 吸收后移除）；受理一站式软门把关、材料消费一次穷尽、任务表依赖拓扑序发号（§三 / §六 / §八 / §九 / §十四 / §十六 / §十七）。

## 十六、插件生命周期：升级与卸载

- **零运行时耦合与卸载裁决**：插件唯一内容是 sdd-init skill，初始化把治理体系复制进目标项目后即断奶，命令、工具、hook 全在项目侧，日常运转不回调插件。卸载插件对已初始化项目零影响，仅失去后续升级通道；**不做项目级拆除**（含清单文档），项目停用体系删除生成文件即可，`pre-commit.sh` 首行 `[ -f sdd/tools/mdlint.sh ] || exit 0` 自防御（删 `sdd/` 后 hook 自动静默放行，不断链），git 历史保全一切，`sdd/runtime/claude.md` 是治理活文档、插件规格不越权处置。
- **升级 = sdd-init 升级模式**：前置检查检测到全套签名文件齐全 → 转「就地合并」而非冲突停止；任一缺失 → 照旧冲突停止并列缺失项，部分存在不触发升级。签名清单、校准细则、验证与回报规格落于 `references/upgrade.md`
  - **撤档（3.0.0）**：升级校准新增撤档动作，现行规格不再生成的文件（finalize / split 命令与存根）从目标项目删除，逐项列入回报
  - **两支线（3.0.0）**：存量 `VERSION` 带 `+slim` / `+full` 后缀视为旧版安装，按后缀识别旧结构走对应支线：full 旧装 = 撤档 + runtime / CONSTITUTION 重生成（4 态、溯源去 edition）+ VERSION 改单值；slim 旧装 = 治理面扩容（INITIATIVE、amendments、archive、templates proposal / task、archive 命令与存根）+ INDEX 构想小节迁出获发 I 号（复用升 full 版迁移）+ 同款重生成
  - 两支线前置闸门照旧（非终态 P 在场拒绝升级，治理数据零迁移）
  - 旧制度遗留的 CHANGELOG `[Unreleased]` 节：升级不自动修改（升级回报提示）；首次 accept 时累积条目并入本次版本节，节随之移除
- **环境重建**：项目在新主机 clone（或 `.git/` 重建）后，客户端 hook 不随 git 目录迁移，`.git/hooks/pre-commit` 必然缺失，运行态齐全，重跑 sdd-init 即命中升级模式并补装 hook（pre-commit 不入签名集，缺失不碍触发）；此属预期动作，非体系损坏。
- **校准三档**：
  - 机械资产静默覆盖：`mdlint.sh`、pre-commit hook 重装、standalone 内层 hook 重装、模板 ×4、命令 ×6、OpenCode 配置与存根
  - 保护性写入：`.gitignore` 逐行补缺或 standalone 排除清单维护、`AGENTS.md`、`sdd/runtime/claude.md` 与 CONSTITUTION 规格重生成 + 项目名回填、CONSTITUTION 生效日期保留原值
  - 活文档仲裁：`sdd/runtime/claude.md` 骨架节按规格重写，`CLAUDE.md` 公开骨架一并重写，被改写处以规格为准并在回报逐项列出；项目填写四字段回读保留，自有增补节原样保留
  - 运行态禁触：INDEX、INITIATIVE、`amendments/amend.md` 内容与 specs/、exploring/、journal、archive/ 全部，骨架仅锚点只读比对，差异报告提示人工迁移，禁自动改
- **版本标记 `sdd/VERSION`**：纯文本单行，内容 = 初始化时插件清单 `plugin.json` 的 `version`（如 `2.8.6`；存量 `+slim` / `+full` 后缀为 3.0.0 前旧版，升级时改单值）；非 `.md`，mdLint 不涉、hook 辖区不拦；入生成清单与第一次提交。用途仅为回报与快速判断；**升级行为永不依版本值分支**：缺失或损坏按旧版安装处理，照常全量校准并回报注明。
- **幂等**：校准按「现行规格 vs 磁盘现状」状态化执行，不询问必填项（从既有文件回读，回读失败为唯一询问点）；升级可安全重跑，中断恢复 = 直接重跑。
- **执行策略**：两路并行，组 U① 治理组（CONSTITUTION 重生成 + INDEX / INITIATIVE / `amend.md` 骨架锚点只读比对），组 U② 机械资产组（命令 ×6、模板 ×4、`mdlint.sh`、hook 含 standalone 内层变体、OpenCode 适配 ×9）；`runtime/claude.md` 仲裁、全量验证、提交与回报由主会话操盘，`runtime/claude.md` 与 `CLAUDE.md` 最后写（同 init 串行屏障）；不支持 subagents 时按 U① → U② → 主会话串行。
- **收尾**：复用 init 全量验证（零 error + 交叉一致），提交按实际变更分两批、零变更批次跳过；前置校验 git 索引干净（`git diff --cached --quiet`），有预置暂存则停止；回报含版本去向、仲裁记录、骨架差异报告与升级耗时。

## 十七、单一 edition（3.0.0 合并）

- **裁定**：slim / full 双轨废止，合并为单一 edition。动机：自动化验证体系（§十九）落地后验收瓶颈消除，slim「少状态提速」的收益归零，而其无分支拓扑成为并行推进的瓶颈；双轨维护成本（历轮修正的 slim 五处对齐）由合并一次性清算。
- **吸收与保留**：吸收 slim 的受理一站式与状态观——4 态（exploring → implementing → verifying → accepted，旁路 on-hold / rejected），`specified` 与 finalize / split 命令撤除，定稿并入 intake、软门把关、可重入直至无疑虑；保留 full 的分支 / worktree / test 泳道验收流水与治理面全套（INITIATIVE、amendments、archive、模板 ×4）。
- **状态与拓扑的推导关系**：状态是工作流机制的账本——verifying 是 test 泳道的验收位账本（合并版认回），`specified` 是定稿 / 拆分边界的账本（一站式受理吸收后无需）。
- **形态与验证体系不受影响**：inline / standalone 正交照旧；自动化验证体系（§十九）为唯一验证工作流。
- **存量迁移**：前置闸门（周期空闲，非终态 P 在场拒绝升级）保证升级时点无在途需求，治理数据零迁移；细节见 §十六撤档与两支线。

## 十八、治理形态（inline / standalone）

- **定位与术语**：治理形态描述治理资产与项目仓的归置关系，init 一并选定。取值 **inline / standalone**，单用不译，中文组合「内联 / 独立」。init 选项行固定为 `治理形态：inline 仓（内联，随项目仓）/ standalone 仓（独立，单独治理仓，默认；init 后不可切换，项目需对外无痕或治理不入项目仓时选此）`。
- **默认与不可切换**：默认 standalone，治理与项目仓解耦、项目仓零痕迹，误入清理成本最低（删独立仓即净，项目仓无痕）。形态 init 后不可切换、无升降通道，升级模式永远维持当前形态；既有低版本安装一律视为 inline；形态仅新项目 init 可选；逃生口 = 重装（治理内容纯文本手工带走、重跑 init 选另一形态、原仓历史留档）。
- **形态判定**：`sdd/` 为独立 git 仓即 standalone，否则 inline，结构自描述、无标记字段。治理资产的本地目录恒为 `sdd/`，与形态无关；远程仓名规格不作约定。
- **统一结构（2.0.0 重组）**：两形态同一棵目录树，治理内容全部在 `sdd/`，内部结构与形态无关。原 `CLAUDE.md` 骨架六节的 sdd 部分移入 `sdd/runtime/claude.md`（头部承载溯源行），原 `AGENTS.md` 适配内容移入 `sdd/runtime/opencode.md`；`CLAUDE.md` 与 `AGENTS.md` 改为项目骨架（项目名、定位一句话，公开内容零 sdd 痕迹），项目名与定位一句话的回读两形态都从公开 `CLAUDE.md` 骨架读取；`opencode.json` 增 `instructions` 加载 runtime 两文件；standalone 增 `CLAUDE.local.md` 指针（`@sdd/runtime/claude.md`）与内层仓（`sdd/` 即内层仓根）。本文件此前各节的「`CLAUDE.md` 骨架 / `CLAUDE.md` 仲裁」表述自本节起由 `sdd/runtime/claude.md` 承接。
- **差异清单（形态差异仅此 10 条）**：

  1. `CLAUDE.local.md` 仅 standalone 生成（指针文件，内容 `@sdd/runtime/claude.md`）。
  2. `CLAUDE.md` 差一行 `@sdd/runtime/claude.md`，inline 有、standalone 无（公开文件零 sdd 痕迹）。
  3. `.gitignore`：inline 三行惯例照写，standalone 一字不动。
  4. 提交去向：inline 一切随项目仓；standalone 治理提交 `git -C sdd` 落内层仓，代码、分支、worktree、tag 永远在外层项目仓。
  5. standalone 排除清单写 `.git/info/exclude` 六行，自足、不依赖项目 `.gitignore`：`sdd/`、`.claude/commands/sdd-*.md`、`.opencode/commands/sdd-*.md`、`.opencode/opencode.json`、`*.local.*`、`.worktree/`。
  6. init 提交：inline 两笔（20+9）；standalone 项目仓一笔中性 message（仅 `CLAUDE.md` + `AGENTS.md`，无 sdd 字样）+ 内仓一笔全量。
  7. 内层 hook 仅 standalone：`sdd/.git/hooks/pre-commit` 按辖区变体生成（内层仓根即治理根，全部 `.md` 入检，首行自防御 `[ -f tools/mdlint.sh ] || exit 0`）。
  8. 脱敏：inline 常规（title/body 无治理 ID、footer 治理引用照记）；standalone 项目仓无痕化（footer 治理引用一律不记、message 中性、分支名与 tag message 照常脱敏）；内层仓提交不设治理引用与脱敏条款（纯文档仓，代码与文档的关联不复存在）。
  9. init 验证与回报带形态变体（文件数、笔数、exclude、内层 hook、`CLAUDE.local.md`）。
  10. 升级按 `sdd/.git` 判形态；standalone 校准治理提交 `git -C sdd`、项目仓零治理提交（公开骨架变更例外，中性 message）、内层 hook 重装；inline 旧安装一次性迁移（规格见 `upgrade.md`）。

- **生成计数**：单一 edition（3.0.0）inline 29 / standalone 30（根 3 + 命令 6 + OpenCode 适配 7 + sdd 13；standalone 不写 `.gitignore`、改生成 `CLAUDE.local.md`，一减一加同数，实现时逐文件核对）。历史计数（双轨期 inline full 31→33 / slim 20→22、standalone 32→34 / 21→23 诸值）见 §十五 沿革，随双轨废止失效。
- **八面表（init 判据素材）**：

  | 受影响面 | inline | standalone |
  |---|---|---|
  | 治理仓与项目仓关系 | 同仓共存 | 另立两仓并存 |
  | 项目仓可见性 | 治理文件入库可见 | 零痕迹 |
  | 历史结构 | 治理与项目同线 | 两段独立历史 |
  | 协作者视角 | clone 开箱可用 | 只见干净项目 |
  | 脱敏强度 | 常规 | 无痕化 |
  | 跨机恢复 | 一条 clone | 两条 clone + 重跑 init |
  | 生命周期 | 与项目仓同生共死 | 治理仓独立存续 |
  | 权限面 | 与项目协作者一致 | 可错开（治理仓私有、项目仓开源） |

- **工作流不变式**：治理形态不改变任何工作流语义，状态转换矩阵、会话微流程、Git 工作流各节仍为唯一描述源；形态仅改上列 4 / 8 两条。tag 永远打在外层项目仓（代码发布）；standalone 下 `sdd/` 不在任何分支里，「检出中 sdd/ 只读」自然成立。
- **跨机恢复**：inline = clone 项目仓；standalone = clone 项目仓 + `git clone <治理仓> sdd/` + 重跑 init 补齐机械资产。

## 十九、自动化验证体系

- **定位**：验收链无人化，AC 绑定什么就验什么，绑命令的自动验证，标人工的沉尾批；自动化程度由项目的验证条件决定，体系不作承诺，auto 模式下人工不在验证路径上。状态机 4 态骨架（旁路 on-hold / rejected）、per-P 验收动作链、test 串行与验收期主干冻结零改动，本体系全部改动收敛在验证域。
- **模式**：`Acceptance mode`（auto / manual，缺省 auto）于 init 询问定型并登记于 runtime 治理配置区，升级回读不到即 auto；auto 模式验证全绿自动走 accept 动作链，manual 模式验收由用户发起（R7 验收节点限 manual）。auto 模式旁通阀：`/sdd-config` 切 manual 后人工验证、`/sdd-accept` 放行，体系不留无闸门的旁通。
- **AC 契约**：
  - spec「验收标准」节由列表改表格（编号 / 验收标准 / 验证方式），模板三源同步
  - 验证方式于定稿一次成型、不回溯、不翻转，合法值为验证命令名或 `人工：<理由>`（人工仅 manual 模式存在，理由如实含现状性表述，如 UI 交互、暂无自动化手段）
  - 落位软门 auto 模式增自查项，全部 AC 已绑定命令方许定稿
- **验证命令区**：runtime 工程约定节新增清单（名称 × 命令 × 类别 × 范围），名称全局唯一（AC 绑定键），类别单测 / 集成 / E2E / 构建，范围引用分区路径或根（非 monorepo 省略即根）；验收某 P 时执行其触达路径前缀命中分区（及仓根）的相关类别命令，未命中分区不跑。现行「提交前校验命令」字段保留不动（pre-commit 契约不变）。
- **登记两条腿**：闸门改述为提交涉及工具链工件类且该类未覆盖时触发（原「首次提交涉及」表述收回）；补记为 init 升级 / 校准插区时存量扫描，命中验证类工件（依赖清单中的测试框架、测试配置、CI 测试任务）生成补记清单，交互同闸门（建议 / 选定 / 判「无」/ 试跑），范围建议取自工件所在分区；补记只是登记补全，不做存量处置。两条腿共用覆盖判据，类目已登记即覆盖。
- **证据制度**：全绿不等于已验证，判定单位是逐 AC 证据；证据 = 验证命令名 · 用例指认 · 输出摘要（人工类记现场结论），摘要写入验收清单随表追加 journal，不依赖外部报告文件入库；映射核对在验收清单编制时点，指认不出覆盖用例即映射失败，按验证失败处理。
- **自动验收链与停驻**：`/sdd-start` 是唯一入口，串行逐 P 或派发并行；全任务 done 的 P 在验收位排队，位空即自动走链（manual 模式由用户发起）；验证失败自动修复重验，重试累计达治理配置 `Verification retry limit`（正整数，缺省 3，不进 init 询问）仍未全绿即停驻（P 置 on-hold，verifying 旁路入；验收位释放、推进继续并即时回报，恢复由对话承载：修复落 dev 后重演 verifying 转换，或切 manual 人工验收放行），状态机无反转。
- **兼容**：
  - 升级项目：活文档差异仲裁插入空验证命令区与治理配置区（区空则 AC 唯一合法值为人工，等于现状），既有工程约定字段回读保留
  - 未升级项目：运行 2.5.0 现行验收规则，运行态 spec 不回填
  - 升级后新定稿 spec 用表格模板，旧 spec 保持列表，验收清单生成按形态路由
- **诚实代价**：假绿是残余风险，证据三件套（用例指认、映射失败即失败、摘要留档）是唯一防线；缺陷发现下放到使用过程（换手工验收工时的明示取舍），走维护路径（覆盖地板，仅单测 / 集成覆盖的 UI 行为，其视觉与交互缺陷只能在用过程中暴露）；人工验收工时转为开发工时，测试是交付物的一部分。
