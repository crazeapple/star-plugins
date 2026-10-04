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
| 命令（7 个） | `/sdd-intake` · `/sdd-finalize` · `/sdd-split` · `/sdd-start` · `/sdd-board` · `/sdd-accept` · `/sdd-archive` |
| 治理文档 | `CONSTITUTION.md`（宪法，根本法）· `INITIATIVE.md`（构想池）· `amendments/amend.md`（修正登记簿）· `INDEX.md` · `exploring/` · `specs/` · `archive/` · `templates/` · `tools/` · `journal.md` |
| ID 前缀 | `I-XXX`（Initiative）· `P-XXX`（Proposal）· `T-XXX`（Task）· `A-XXX`（Amendment） |
| 状态 | Proposal：`exploring` / `specified` / `implementing` / `verifying` / `accepted` / `on-hold` / `rejected`；`done` 唯一属于 Task；design：`draft → finalized` |

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
新需求（含插单）→ /sdd-intake
  ├─ 维护/需求分类三问 → 判维护：直接做并回报，intake 即结束
  ├─ 听需求 → 第一轮产品澄清 → 单/多交付物判定（对话产出，非门槛，可修正）
  ├─ 单交付物（XS/S/M 皆可）→ 直接发 P-XXX（无 source，不进池）→ 既有状态机
  └─ 多交付物/模糊大需求 → INITIATIVE.md 立 I 条目（原文保留）→ 继续拆解
       → 发 P-XXX（source: I-XXX，用户确认）→ 既有状态机
误入池出口：拆解后发现实为单交付物 → 关闭 I 条目，直接发 P（无 source）
```

- **单交付物判据 = 三问测试**（见第七节）：XS/S/M 只要装得进一个可独立验收的 Proposal 就直接发号。**I 只为「结构」而生**：需要产品层结构（多里程碑、多子产品、路线图）时 I 才有意义，单块交付的需求里 I 只是 P 的影子。
- 两路各付一种代价，已确认为更优解：两路付「每次判断」的成本，换取小需求不被 I/P 重复登记。

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

「为系统添加用户登录功能」，intake 对话：分类三问判为需求（新能力）；第一轮澄清（登录方式、注册、找回）的落点是 P 的 exploring 文件（工程层）；单交付物判定成立，登录是一个可独立验收的功能块，其复杂性全在工程层（session vs JWT、哈希算法、防爆破等选型），产品结构上就是一块。**直接发 P-XXX（无 source）**→ exploring（认证选型在此探索）→ finalize（spec：AC 细化 + 边界）→ split（Task：注册/会话/安全/找回）→ start → accept。

教训：**I 与 P 的分界不是需求大小，而是是否需要产品层澄清与路线图，即「大 ≠ 进池」**。

### 案例二：完整账号体系 → I

「做完整的账号体系：个人/企业账号、SSO、组织权限」，产品级构想，需要路线图，`INITIATIVE.md` 立 `I-XXX` 条目（原文保留；路线图：账号 → SSO → 组织权限）→ 逐个拆出 P，登录注册、SSO 集成、组织权限（各标 `source: I-XXX`）→ 各自走状态机 → 全部 accepted 后 I 标完结。

## 九、探索行为规则（R3）

探索质量是行为问题而非结构问题，规则四条：

1. **自顶向下**：先问题空间（目标、用户、场景、约束）→ 再方案空间（架构方向 → 模块划分 → 关键接口），逐层细化；方向未定禁止钻实现细节。
2. **先发散后收敛**：每个关键决策点先列 ≥2 个候选方向（至少 1 个保守或非常规方案，防锚定）；场景覆盖正常流、异常流、边界条件、非功能诉求。
3. **逐层留痕**：细化过程实时写入底稿，而非事后补写，跨会话中断可恢复；用户给出的内容同样落盘。落盘义务贯穿提案全程：过程写底稿（存活至验收或 rejected 终结），结论演进写 spec changelog。
4. **finalize 软门**：执行前自查，候选方案有倾向与理由、开放问题全部收敛（已解决或显式转为假设记录）；不满足则回报并建议继续探索。软门不设硬性准入清单，避免仪式感转移。

## 十、自治阶梯（判断自动，动作守门）

| 层级 | 事项 |
|---|---|
| 自动执行，做完告知 | 维护/需求分类判断、维护直接做、新想法落池、三问执行、XS 产物极短化、R1 摘要、board 聚合 |
| 判断 + 明示理由，可一句话推翻 | 建议立项、on-hold 排队建议 |
| 永远用户守门 | 发号（P）、授予 I、finalize、accept、停损升级、archive、决策反转入册（A）、写实现代码 |

## 十一、滚动立项、完结联动与插单

- **滚动立项**：`/sdd-accept` 完成回报固定追加「回看需求组拆下一个」（复用 R7 人工确认）；需求组最后一个 P accepted **不建议归档**，归档是项目尾声的整体动作，由用户主动发起。
- **完结联动**：组内全部 P accepted → I 标完结 → 归档时条目内容并入 `requirements.md`（需求来源章节）后从 `INITIATIVE.md` 移除；丢弃条目同理。`INITIATIVE.md` 常态只保留活跃需求组。
- **插单四条**：
  1. 落池不打断，新想法当场判层：当前 P 范围内走 R5；组内新里程碑追加路线图备注；无关想法入 `INITIATIVE.md` 新条目（raw）。当前 P 永不因新想法自动中断。
  2. 处理时复用三问测试分流。
  3. 排队用 on-hold：新 P 不立刻做则置 on-hold（排队/搁置两用），状态机零改动。
  4. 切换仅三情形：阻塞当前 P、用户明确要求、决策/方案类修正走 `amendments/`。
- **R1 冷启动加读 `INITIATIVE.md`**：摘要含构想池概览（活跃 I 数、待梳理条目、未立项里程碑）；AI 不主动催梳理。
- **`/sdd-board` 聚合**：输出按 `source` 聚合的需求组进度段（如 I-002：P-010 accepted / P-011 implementing / 2 个里程碑未立项）；INDEX 不加列。

## 十二、治理不变式

- 状态机七态骨架与禁止跳跃
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
  | ② | 命令 ×7（`.claude/commands/`） | command-specs + constitution-design「状态转换 × 文档同步矩阵」节（定点读取） |
  | ③ | 模板 ×4（纯复制）、`tools/mdlint.sh`（纯复制）、archive/README | 近乎零 |
  | ④ | OpenCode 适配 ×10 | opencode-adapter 全文 |

- **串行屏障**：`sdd/runtime/claude.md` 与 `CLAUDE.md` 最后由主会话写（引用全部生成物）；汇合后必须由主会话执行「验证与回报」全量校验（mdLint 全量重跑 + 交叉一致），通过后按治理形态提交（§十八）。
- **计时回报**：起始时间戳（`date +%s`）记于前置检查起点，收尾取结束时间戳算差值；最终回报含「初始化耗时」，仅报总时长（人类可读格式），不分阶段。
- **一致性来源**：并行不破坏逐字纪律，各组照抄单源规格，交叉一致由全量校验兜底。
- **成本核算**：各组自读规格合计约 9-10k input tokens（串行生成约 6k），差额以美分计，换取生成时长约减半；主会话不读规格、不持有生成文件全文，上下文更省。
- **回退**：运行环境不支持 subagents 时，按组序串行生成，其余步骤不变。
- **升级模式**：既有安装的就地合并走 sdd-init 升级模式，其执行策略见 §十六。

## 十四、Git 工作流（分支开发，主干发布）

- **粒度与时机**：分支以 P-XXX 为单位、双分支制，`dev/<标题英文 slug>`（开发）与 `test/<标题英文 slug>`（验收）。`/sdd-split` 创建（specified→implementing，可写码起点），从 main 切出 `dev/<slug>` 并建 worktree（检出 dev）；全任务 done（verifying）：从当前 main 切出 `test/<slug>`、合并 `dev/<slug>` 入 test（冲突一律在 test 解决）、删除 worktree 与 dev 分支，代码进入验收，worktree 使命终结。两级并行：分支 = P（提案间），分支内派发-回收子 Agent = T（提案内）。
- **载体统一 worktree**：`git worktree add .worktree/<标题英文 slug> -b dev/<标题英文 slug>` 创建（分支 + 工作区一步，目录名与分支名同源）；`.worktree/` 入 `.gitignore`；主工作区常驻主干；验收测试在主工作区检出 `test/<slug>` 进行（主工作区即用户可运行环境）；单/多 Agent 同一机制，无例外。
- **test 串行与主干冻结**：全流程同时至多一个 P 持有 `test/<slug>`，test 恒从当前最新 main 切出（提案间并行展开于 implementing 层，验收串行）；验收位被占用时，全任务 done 的 P 留在 implementing 等待（任务表保持全 done，worktree 与 dev 分支保留），待在途 test accept 后再执行 verifying 转换。验收期（test 切出至 accept）内 main 代码不前进（治理文档主干直写照旧）：一切修复（无论缺陷源自哪个 P 的范围，含不进 Proposal 的维护性修复）都落在当前 `test/<slug>`，随本 P accept 一并进 main；验收期外维护仍直接落 main。验收位空闲保证切出时 main 已含全部在先成果，验收期冻结保证 accept 合并恒无冲突。
- **治理文档主干单线**：sdd/ 全部治理文档只在主干由主会话写；分支只承载实现代码。git 拓扑映射治理架构：代码层并行（分支），治理层串行（主干）。会话工作目录不设限，以路径锁定「什么写在哪」：治理文档写主工作区，代码写 worktree；test / dev 检出中的 sdd/ 一律只读，治理写入回主工作区 main。
- **提交**：治理文档由状态转换命令收尾自动提交主干（信息现场自拟，遵循脱敏与治理引用约定；落仓按治理形态，见 §十八）；dev 分支代码提交以 Task 为界，单个提交不混多 Task 改动，Task 完成即提交、一 Task 可多提交；test 分支的修复提交随验收产生；代码合入主干发生在全任务 done 的 verifying 转换（合并 dev → test，accept 发布 test → main），accept 不再合并代码；交付 hash（dev → test 合并）记入 `design.md`；代码提交前须通过项目提交前校验（lint、format、测试等，以项目工程约定为准）；push 永远手动。
- **tag**：accept 收尾（治理提交之后）打 annotated tag，版本格式于首次 tag 时询问用户定型，CalVer（`YYYY.M.D` 验收日，同日多验收追加当日序号）或 SemVer（`vX.Y.Z`，按变化递增）；信息取本次 CHANGELOG 条目首行（遵循脱敏约束）。tag = 发布门槛：主干可短暂承载 verifying 代码，打 tag 才是发布标记。
- **CHANGELOG**：accept 收尾、打 tag 之前增补 `CHANGELOG.md`（项目根公开文件；不存在则创建，含 Keep a Changelog 风格说明头，新版本在上）。条目范围 = 本次 tag 与上一 tag 之间；内容三源锚定（本次 accepted 提案 spec「范围内」、INDEX 提案行、区间 git log 提交主题，含直接落主干的维护修复），禁凭空杜撰；分类四类「新增 / 变更 / 修复 / 移除」；统一不含治理 ID 与治理词汇（说用户语言，edition 与形态无关）；生成后随 accept 完成回报展示，用户守门可改。落仓：inline 随治理提交，standalone 为外层公开文件随中性 message 提交；辖区入外层 hook。
- **验收清单表格**：全任务 done 时主会话列出（五列：AC / 验收标准 / 证据 / 人工测试步骤 / 结论；验收标准与 spec 逐字一致），会话输出不落盘，供用户人工测试；accept 逐条以实际证据核对（结论通过置 ✅），通过后整表追加 journal 作为验收记录；未全过不置 accepted，Task 保持 done，缺陷修复提交以 footer 记 `Fixes: T-XXX` 回链 Task。
- **脱敏与治理引用**：分支名与 tag message 不含治理 ID 与治理文件名；commit message 的 title 与 body 不含治理 ID 与治理文件名；需要引用治理实体时，在 footer 区（body 后空一行、逐行）按 trailer 惯例记，关键词随本提交对实体的作用而定，无引用则不写（Task 完成 → `Closes: T-XXX`，accept 验收提案 → `Closes: P-XXX`，验收阶段修复已完成 Task 的缺陷 → `Fixes: T-XXX`，一 Task 多提交时的非收尾提交等 → `Refs: T-XXX`）；开发过程中的自我修正不属修复语义，随所在 Task 完成提交记；Task 完成只记代码侧提交，主干治理提交不重复记；footer 区可并存项目自有 trailer，也可有多个 trailer；分支名 = `dev/<标题英文 slug>` 与 `test/<标题英文 slug>`，记一行入 `design.md`；治理层实现记录可引用 commit hash（中性回链）。
- **终局**：accept 后删除 `test/<slug>`；rejected 分环节清理。exploring / specified 未建分支，底稿 / 规格入档（标注 rejected）后删除；implementing 删 worktree 与 `dev/<slug>`；verifying 删 `test/<slug>`，main 零沾染（test → main 合并只发生在 accept 内）；on-hold 挂起保留（worktree 与分支挂起）。主干承载 verifying 代码，发布门槛 = tag（发布动作不入 SDD 流程）。

## 十五、落地阶段

1. **设计**：本文件即设计总纲，交仓库所有者审阅。
2. **规格实现**：已按本设计完成 `plugins/sdd/skills/sdd-init/` 的实现，含 `SKILL.md`、references ×4（constitution-design / command-specs / opencode-adapter / upgrade）、templates ×4（proposal/spec frontmatter 含 `source` 行；INITIATIVE 条目结构入模板）；生成清单 29 文件（含 `INITIATIVE.md` 与版本标记 `sdd/VERSION`），两次提交 19+10；工具 `scripts/` ×2（`mdlint.sh`、`pre-commit.sh`，后者安装为目标项目 `.git/hooks/pre-commit`，提交兜底、不入库，唯一机械强制 hook）；命令规格表与 OpenCode 存根同步。edition 体系（§十七）落笔时增补：references 增 `slim.md`（slim 生成 / 校准 / 升 full 版逐字规格），`templates/slim/` 增 spec / design ×2，slim 生成清单 18 文件、两次提交 11+7。治理形态（§十八）落笔时增补（2.0.0）：统一结构重组（runtime ×2、`CLAUDE.md` / `AGENTS.md` 改项目骨架），references ×5 与 PROMPT-SDD 增形态分支，`scripts/` 增 `pre-commit-inner.sh`（内层 hook 变体），生成计数 inline full 31 / standalone 32、slim 20 / 21。slim 发布标记增补（2.0.1）：accept 打 annotated tag，发布语义与 full 对齐（§十七）。CHANGELOG 增补（2.1.0）：accept 收尾、tag 之前增补项目根 `CHANGELOG.md`（§十四），两 edition 统一，tag 信息取条目首行。test 串行与主干冻结增补（2.1.1）：test 串行（验收位唯一）、冲突一律在 test 解决、验收期内 main 代码不前进（§十四）。公开骨架减负（2.1.2）：`CLAUDE.md` 与 `AGENTS.md` 项目骨架删去智能体协作声明行（入口自解释，最小公开面）（§十八）。书写判据加固（2.1.3）：治理 ID 一律裸写、禁入行内代码并入 mdLint 执法（行内代码内出现即 warning）；文件名与键名组合必包、链接地址裸写（CONSTITUTION「Markdown 书写规范」）。

## 十六、插件生命周期：升级与卸载

- **零运行时耦合与卸载裁决**：插件唯一内容是 sdd-init skill，初始化把治理体系复制进目标项目后即断奶，命令、工具、hook 全在项目侧，日常运转不回调插件。卸载插件对已初始化项目零影响，仅失去后续升级通道；**不做项目级拆除**（含清单文档），项目停用体系删除生成文件即可，`pre-commit.sh` 首行 `[ -f sdd/tools/mdlint.sh ] || exit 0` 自防御（删 `sdd/` 后 hook 自动静默放行，不断链），git 历史保全一切，`sdd/runtime/claude.md` 是治理活文档、插件规格不越权处置。
- **升级 = sdd-init 升级模式（一个入口两种模式）**：前置检查检测到全套签名文件齐全 → 转「就地合并」而非冲突停止；任一缺失 → 照旧冲突停止并列缺失项，部分存在不触发升级。签名清单、校准细则、验证与回报规格落于 `references/upgrade.md`。
- **环境重建**：项目在新主机 clone（或 `.git/` 重建）后，客户端 hook 不随 git 目录迁移，`.git/hooks/pre-commit` 必然缺失，运行态齐全，重跑 sdd-init 即命中升级模式并补装 hook（pre-commit 不入签名集，缺失不碍触发）；此属预期动作，非体系损坏。
- **校准三档**：机械资产静默覆盖（`mdlint.sh`、pre-commit hook 重装、standalone 内层 hook 重装、模板 ×4、命令 ×7、OpenCode 配置与存根）；保护性写入（`.gitignore` 逐行补缺或 standalone 排除清单维护、`AGENTS.md`、`sdd/runtime/claude.md` 与 CONSTITUTION 规格重生成 + 项目名回填、CONSTITUTION 生效日期保留原值）；活文档仲裁（`sdd/runtime/claude.md` 骨架节按规格重写，`CLAUDE.md` 公开骨架一并重写，被改写处以规格为准并在回报逐项列出；项目填写三字段回读保留，自有增补节原样保留）；运行态禁触（INDEX、INITIATIVE、`amendments/amend.md` 内容与 specs/、exploring/、journal、archive/ 全部，骨架仅锚点只读比对，差异报告提示人工迁移，禁自动改）。
- **版本标记 `sdd/VERSION`**：纯文本单行，内容 = 初始化时插件清单 `plugin.json` 的 `version` + `+edition`（如 `0.2.0+full`，edition 取值见 §十七）；非 `.md`，mdLint 不涉、hook 辖区不拦；入生成清单与第一次提交。用途仅为回报与快速判断；**升级行为永不依版本值分支**：缺失或损坏按旧版安装处理，照常全量校准并回报注明。
- **幂等**：校准按「现行规格 vs 磁盘现状」状态化执行，不询问必填项（从既有文件回读，回读失败为唯一询问点）；升级可安全重跑，中断恢复 = 直接重跑。
- **执行策略**：两路并行，组 U① 治理组（CONSTITUTION 重生成 + INDEX / INITIATIVE / `amend.md` 骨架锚点只读比对），组 U② 机械资产组（命令 ×7、模板 ×4、`mdlint.sh`、hook 含 standalone 内层变体、OpenCode 适配 ×11）；`runtime/claude.md` 仲裁、全量验证、提交与回报由主会话操盘，`runtime/claude.md` 与 `CLAUDE.md` 最后写（同 init 串行屏障）；不支持 subagents 时按 U① → U② → 主会话串行。
- **收尾**：复用 init 全量验证（零 error + 交叉一致），提交按实际变更分两批、零变更批次跳过；前置校验 git 索引干净（`git diff --cached --quiet`），有预置暂存则停止；回报含版本去向、仲裁记录、骨架差异报告与升级耗时。

## 十七、edition 体系（slim / full）

- **定位与判据**：sdd 提供两个 edition，**full（完整版）**与 **slim（精简版，full 的真子集）**。edition 选择由用户决定，任何项目均可选任一 edition；以下判据仅为**建议性参考**，辅助自评，即 **需求明确性**（需求是否具体明确）、**探索与验证节奏**（是否需要探索与方案对比，还是快速验证迭代，探索越重越适合 full）、**规模 × 时间**（开发周期越长，文档治理往往要求越严格规范以防随开发腐化，规模越大越适合 full）。一般而言 slim 适合需求明确、规模可控、追求快速验证的项目；维度偏重时更推荐 full。
- **术语**：概念英文名 edition（单用不译）；取值 `slim` / `full`；中文行文组合译「版」，即 slim 版 / full 版。
- **单插件选 edition**：不做独立插件；sdd-init 初始化时选 edition（**默认 slim**：slim 可升 full 而反向无通道，默认取可逆方向），全部询问项默认兜底、无硬阻塞停止点（项目定位以候选制提供，标注默认，未答取默认）。slim 命令与 full 同名且为子集（intake / start / board / accept）；slim 规格独立成篇 `references/slim.md`（无条件分支、自成一篇），**edition 分叉只发生在 `SKILL.md` dispatch 层**，按 edition 决定读哪套规格，full 侧 references 一字不改。
- **不变量与裁剪准则**：状态单一权威源（INDEX）、mdLint + pre-commit 机械兜底、需求 / 维护分类、验收标准 + 变更留痕，任何 edition 不可裁；裁剪准则 = 裁仪式，不裁纪律、权威与能力。
- **git 拓扑按 edition**：分支拓扑（`dev/<slug>` 开发 + `test/<slug>` 验收 + worktree + 合并链）为 full 载体；slim 无分支、主工作区直写（主工作区即测试环境），rejected 代码由 git 历史兜底。通用的是验收语义链与纪律，不是拓扑；分支治理需求出现时升级 full 版。发布语义两 edition 同构：accept 打 annotated tag（full 在 main，slim 在当前分支 HEAD），tag 不属拓扑差异。
- **状态值子集**：slim 状态值 ⊆ full 状态值，不新造状态词（P：`exploring → implementing → accepted`，旁路 `on-hold` / `rejected`；`specified` / `verifying` 不用于 slim）；值不合适时改 full 对齐，运行态永无跨 edition 未知状态。
- **单向可升**：slim → full 单向升级，无降档（文档不涉及降档）；切换频率极低，价值主体 = 初始选 edition + slim 常驻。
- **升级闸门**：升 full 版要求周期空闲，INDEX 存在非终态 P（`exploring` / `implementing` / `on-hold`）时拒绝切换并回报「请完成当前需求周期后再升级」，**无 override**；同 edition 校准（含环境重建）不设周期闸门（幂等 + 运行态禁触 + 索引干净预检已覆盖）。
- **识别与可见面**：权威源 = `sdd/VERSION` 单行 `version+edition`（如 `0.2.0+slim`，格式 `^[0-9]+\.[0-9]+\.[0-9]+\+(slim|full)$`，识别取 `+` 后段，full 不省略后缀）；显示层为派生写入，`sdd/runtime/claude.md` 头部溯源行（`sdd@star-plugins <版本> · edition：slim`，缺席命令解释置于命令一览节补充说明）、CONSTITUTION 头部溯源行（`sdd@star-plugins <版本> · edition：slim`）、命令输出自报 edition。版本值永不参与分支；**升 edition 判据不由数据自动触发**（否决 INDEX 规模列自动升档建议）。
- **升级入口**：不新增 upgrade 命令，§十六「一个入口两种模式」扩展为前置检查四出口 dispatch（全新 / slim 命中 / full 命中 / 冲突即停）；slim 命中走单问题默认兜底（回车 = slim 原地校准，显式确认 = 升 full 版）；slim 校准与升 full 版规格落 `references/slim.md`，`upgrade.md` 承载 edition 路由。
- **与治理形态正交**：edition 与治理形态（§十八）两轴独立，init 一并选定；slim → full 升级保形态不换仓。

## 十八、治理形态（inline / standalone）

- **定位与术语**：治理形态描述治理资产与项目仓的归置关系，与 edition 轴正交，init 一并选定。取值 **inline / standalone**，单用不译，中文组合「内联 / 独立」。init 选项行固定为 `治理形态：inline 仓（内联，随项目仓，默认）/ standalone 仓（独立，单独治理仓；init 后不可切换，项目需对外无痕或治理不入项目仓时选此）`。
- **默认与不可切换**：默认 inline，多数项目的自然期望，且与既有安装行为一致。形态 init 后不可切换、无升降通道，升级模式永远维持当前形态；既有低版本安装一律视为 inline；standalone 仅新项目 init 可选；逃生口 = 重装（治理内容纯文本手工带走、重跑 init 选另一形态、原仓历史留档）。
- **形态判定**：`sdd/` 为独立 git 仓即 standalone，否则 inline，结构自描述、无标记字段。治理资产的本地目录恒为 `sdd/`，与形态无关；远程仓名规格不作约定。
- **统一结构（2.0.0 重组）**：两形态同一棵目录树，治理内容全部在 `sdd/`，内部按 edition 分叉、与形态无关。原 `CLAUDE.md` 骨架六节的 sdd 部分移入 `sdd/runtime/claude.md`（头部承载 edition 溯源行），原 `AGENTS.md` 适配内容移入 `sdd/runtime/opencode.md`；`CLAUDE.md` 与 `AGENTS.md` 改为项目骨架（项目名、定位一句话，公开内容零 sdd 痕迹），三字段回读两形态都从公开 `CLAUDE.md` 骨架读取；`opencode.json` 增 `instructions` 加载 runtime 两文件；standalone 增 `CLAUDE.local.md` 指针（`@sdd/runtime/claude.md`）与内层仓（`sdd/` 即内层仓根）。本文件此前各节的「`CLAUDE.md` 骨架 / `CLAUDE.md` 仲裁」表述自本节起由 `sdd/runtime/claude.md` 承接。
- **差异清单（形态差异仅此 10 条）**：

  1. `CLAUDE.local.md` 仅 standalone 生成（指针文件，内容 `@sdd/runtime/claude.md`）。
  2. `CLAUDE.md` 差一行 `@sdd/runtime/claude.md`，inline 有、standalone 无（公开文件零 sdd 痕迹）。
  3. `.gitignore`：inline 三行惯例照写，standalone 一字不动。
  4. 提交去向：inline 一切随项目仓；standalone 治理提交 `git -C sdd` 落内层仓，代码、分支、worktree、tag 永远在外层项目仓。
  5. standalone 排除清单写 `.git/info/exclude` 六行，自足、不依赖项目 `.gitignore`：`sdd/`、`.claude/commands/sdd-*.md`、`.opencode/commands/sdd-*.md`、`.opencode/opencode.json`、`*.local.*`、`.worktree/`。
  6. init 提交：inline 两笔（full 21+10、slim 13+7）；standalone 项目仓一笔中性 message（仅 `CLAUDE.md` + `AGENTS.md`，无 sdd 字样）+ 内仓一笔全量。
  7. 内层 hook 仅 standalone：`sdd/.git/hooks/pre-commit` 按辖区变体生成（内层仓根即治理根，全部 `.md` 入检，首行自防御 `[ -f tools/mdlint.sh ] || exit 0`）。
  8. 脱敏：inline 常规（title/body 无治理 ID、footer 治理引用照记）；standalone 项目仓无痕化（footer 治理引用一律不记、message 中性、分支名与 tag message 照常脱敏）；内层仓提交不设治理引用与脱敏条款（纯文档仓，代码与文档的关联不复存在）。
  9. init 验证与回报带形态变体（文件数、笔数、exclude、内层 hook、`CLAUDE.local.md`）。
  10. 升级按 `sdd/.git` 判形态；standalone 校准治理提交 `git -C sdd`、项目仓零治理提交（公开骨架变更例外，中性 message）、内层 hook 重装；inline 旧安装一次性迁移（规格见 `upgrade.md`）。

- **生成计数**：inline full 31 / slim 20；standalone full 32 / slim 21（= 现基线 + runtime ×2，standalone 再 +`CLAUDE.local.md`，实现时逐文件核对）。
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

- **工作流不变式**：治理形态不改变 slim / full 的任何工作流语义，状态转换矩阵、会话微流程、Git 工作流各节仍为唯一描述源；形态仅改上列 4 / 8 两条。tag 永远打在外层项目仓（代码发布）；standalone 下 `sdd/` 不在任何分支里，「检出中 sdd/ 只读」自然成立。
- **跨机恢复**：inline = clone 项目仓；standalone = clone 项目仓 + `git clone <治理仓> sdd/` + 重跑 init 补齐机械资产。
