# 更新日志

本仓发布以 tag 为版本，每个版本列出当次包含的 sdd 插件版本节点。格式参照 Keep a Changelog，条目分「新增 / 变更 / 修复 / 移除」四类，新版本在上。

## [2.3.0] - 2026-10-10

### sdd v3.5.1

#### 修复

- 导出同日计数改为按参数计数（「同日同参第 N 份缀 `+N`，首发不缀」）：`tech` 作为当日第 2 次导出不再误得 `+2`，同参第二份才缀；此前全局计数使首发 tech 文件名出现无来历的序号

### sdd v3.5.0

### sdd v3.5.0

#### 新增

- 命令参数提示：command-specs 规格表增「参数提示」列，生成命令 frontmatter 增 `argument-hint`，输入命令时行内可见（intake `[<需求描述>|<文档路径>...]`、start `[P-XXX|T-XXX]`、accept `<P-XXX>`、board `[I-XXX|P-XXX]`、export `[req|tech|all]`、config `[<配置项> <新值>]`）

#### 变更

- 命令规格表「动作依据」列瘦身为矩阵指针：有矩阵行者只引行名（消除与矩阵的重复漂移，start cell 的旧停驻语义残留一并清除），board / config 无宪法专节、保留原 cell；矩阵行名 `→` 后统一补空格（宪法与 PROMPT 两份矩阵同步）

### sdd v3.4.0

### sdd v3.4.0

#### 变更

- init 计时与加速：耗时统计自询问完成（全新）与模式判定完成（升级）起算至收尾回报；询问限时 3 分钟，先答复按答复、到点未答按默认值继续（后台计时，不可用即降级为等待答复）；项目描述缺省「待定」，首个提案受理时补问；生成并行重构（四路 subagent 改两路 + 主会话直接复制模板与工具）；OpenCode 验证三段并两段（命令发现并入冒烟建议），opencode 可用性检测与询问并行

### sdd v3.3.1

### sdd v3.3.1

#### 修复

- runtime 溯源行残留 `· edition：full`（command-specs 骨架节 3.0.0 合并漏改，与 upgrade「溯源去 edition」口径相抵）；连带修正 DESIGN 生成计数停于 3.0.0、PROMPT 的 VERSION 识别正则仍卡 `+slim` / `+full` 后缀、standalone 同数误写 31（一减一加应同数 30）

## [2.2.0] - 2026-10-09

### sdd v3.3.0

#### 变更

- 归档改为导出：`/sdd-archive` 退役，新 `/sdd-export` 随时可用、零副作用（只读治理状态，不写 INDEX、不移除条目、不冻结治理文档，「归档后只读」硬规则撤销）；参数 `req` / `tech`、无参即 `all`，单文件概括生成落项目根 `.export/`（不入库、两形态同用 info/exclude 排除），覆盖全部提案不分状态与全部 I（含未开发），产物说用户语言、不含治理 ID 与源项目信息，完成回报列覆盖清单；生成清单 30 文件（17 治理，standalone 同数 31）、提交分批 20 + 10

#### 移除

- 归档四产物与 REUSE-GUIDE、`sdd/archive/` 区、INDEX「已归档」标记、R7 关键节点中的归档建议

#### 修复

- PROMPT 可移植版升级节残留：守门清单 `finalize`、命令与存根计数 7（现行 6）、签名集含 `sdd/archive/README.md`、R8「归档后只读」旧语义

## [2.1.0] - 2026-10-09

### sdd v3.2.0

#### 新增

- lint / format 门禁与登记案例：宪法增「登记案例」节（frontend / sql / shell / yaml 四枚，案例名一级三类二级 bullet，自查表定位非照搬源，触发后经对话由用户选择确认、不静默添加，沉淀回流由用户摘回成案例）；登记三时机（spec 技术决策定稿为主时机、闸门检测工具链未配置、人工主动兜底），闸门交互改为现场扫描后对照登记案例匹配（替代原候选工具泛泛建议）；验证命令区增 staged 处置列（写回 / 断言 / 不参与）并取消独立「提交前校验命令」字段

#### 变更

- 提交兜底改提交门禁：hook 由 `.git/hooks/pre-commit`（不入库）迁移 `.githooks/pre-commit`（入库占清单，`core.hooksPath` 激活，README 记激活行，R1 冷启动断言），内嵌 mdlint 段与工具链路由段，mdLint 辖区扩为全部 staged `.md`，工具链按文件模式路由执行二元分工（先写回重暂存后断言）；归属原则「治理层级跟资产走，不跟恰好存在的子项目走」，既有 hook 设施（husky、已设 core.hooksPath）列为冲突项；生成清单 29 → 31（standalone 同数 32）、提交分批 20 + 9 → 21 + 10；`mdlint.sh` 注释与输出文案中性化（逻辑与检查集零变化）

#### 修复

- PROMPT 可移植版同步漏网：VERSION `+full` 后缀残留、升级区命令计数 ×8 与适配 ×11 旧值归正为 ×6 / ×9

### sdd v3.1.0

#### 变更

- init 询问重排与形态默认调整：选项顺序改为项目名 / 项目定位一句话 / 治理形态 / 版本格式 / 验收模式；治理形态默认由 inline 改为 standalone（治理与项目仓解耦、项目仓零痕迹、误入清理成本最低），init 后不可切换与既有安装判定（低版本一律视为 inline）不变；「验证模式」正名「验收模式」，与登记键 `Acceptance mode` 对齐，键名与取值不变
- 「流水」术语更名「验收链」：自动验收流水、验收流水无人化、test 泳道验收流水等表述统一为链，on-hold 停驻条文的推进流语义改「推进继续」，消除与流水账的联想

#### 修复

- 3.0.0 合并同步漏网对齐：DESIGN §十九 残留 2.6.0 旧语义（状态机七态、停驻验收位留驻）修正为 4 态与 on-hold 释放语义；PROMPT 可移植版矩阵与 R6 同步现行条款（verifying 转换 worktree 与 dev 分支删除时点后移至 accept、停驻 on-hold 化、accept 残支清理、rejected 清理撤 `specified` 残留）

## [2.0.0] - 2026-10-08

### sdd v3.0.0

#### 变更

- slim / full 双轨废止，合并为单一 edition：吸收 slim 的受理一站式与 4 态状态观（撤 `specified` 与 finalize / split 命令，定稿并入 intake、落位软门、可重入），保留 full 的分支 / worktree / test 泳道验收流水与治理面全套；存量安装经升级模式两支线迁移（`+full` 旧装撤档、`+slim` 旧装治理面扩容与构想小节迁出获发 I 号），周期空闲闸门照旧、治理数据零迁移；`sdd/VERSION` 单值化（旧 `+slim` / `+full` 后缀识别旧版）
- 停驻 on-hold 化：验收重试达 `Verification retry limit` 的 P 置 on-hold（verifying 旁路），验收位释放、流水继续；恢复由对话承载——修复落 dev，重演 verifying 转换（自当前 main 切 `test/<slug-N>` 合并 `dev/<slug>`），或切 manual 人工验收放行；verifying 转换的 worktree 与 dev 分支删除时点后移至 accept
- 升级新增撤档动作与存量补记：现行规格不再生成的文件从目标项目删除；验证命令区插空后按扫描清单补记；遗留 CHANGELOG `[Unreleased]` 节首次 accept 吸收后移除

### sdd v2.8.7

#### 修复

- CHANGELOG 单次写入制：实现期零写入（显著变化由 design 任务清单承载），accept 时单次写入成文——条目两路（对照 spec 与任务清单的用户可感知变化按六类归类、自上次 tag 以来提案外提交的维护修复并入），版本两段式（SemVer 级别对话期议定或 accept 按本次变化推导、自上次 tag 递增成号；CalVer 即验收日），节标题按格式（SemVer 附验收日、CalVer 即日期），常驻 `[Unreleased]` 节取消

## [1.7.4] - 2026-10-07

### sdd v2.8.6

#### 修复

- slim 提交粒度补齐与宪法码律拆分：「代码与 Task 绑定」话题式标签拆为「无 Task 不写码 / 提交以 Task 为界 / 验收期修复回链」三则（限需求治理周期，维护不经本条），slim 补齐以 Task 为界的提交粒度纪律（E2E 实证 slim + standalone 批量推进后外层仓提交稀疏）；§十七 明示提交粒度为通用纪律

## [1.7.3] - 2026-10-07

### sdd v2.8.5

#### 修复

- sdd-split 任务表依赖拓扑序引称补齐：任务表按依赖拓扑序排列（被依赖者先号，无依赖者按逻辑递进），与 2.8.4 intake 侧对齐（宪法条款已泛化覆盖 T 发号，补执行面可见性）

### sdd v2.8.4

#### 修复

- 文档受理建档时机与发号序：确认通过后随落位建档，确认未过或零落位（全部条目已被治理账覆盖）不立任何档、仅回报覆盖对照；多实体发号增依赖拓扑序（被依赖者先号，无依赖者按逻辑递进），发号后永不重排；材料消费一次穷尽正向表述，节奏控制在落位之后（推进编排归用户）

## [1.7.2] - 2026-10-06

### sdd v2.8.3

#### 修复

- standalone 生成计数纠正：standalone 不写 `.gitignore`、改生成 `CLAUDE.local.md`，一减一加与 inline 同数（full 33 / slim 22）；2.0.0 起「再 +`CLAUDE.local.md`」口径漏对应减项，历次 standalone 计数均多一，现行落点（§十八 / SKILL / slim / PROMPT）全部纠正

## [1.7.1] - 2026-10-06

### sdd v2.8.2

#### 修复

- sdd-config 完成回报辖区限定为配置项本身（`Acceptance mode` / `Verification retry limit`），工程约定其余字段（版本格式等 init 定型项）不再进入回报

## [1.7.0] - 2026-10-06

### sdd v2.8.1

#### 修复

- OpenCode 验证面适配 v2：`opencode debug config` 自 v2 仅列配置来源、不再呈现命令，验证改三段式（配置面 debug config 断言 `"lsp": true` 与 `instructions`、存根契约文件核验、命令发现以 `opencode run '/sdd-board'` 的看板摘要与退出码为判据，模型或凭据未配置时跳过该段并回报注明）；机制依据更新核实记录（2026-10 实测 v2.0.22，命令注册无模型无关结构验证面）

### sdd v2.8.0

#### 新增

- 工具可用性实证条款：宪法新增「工具可用性实证」节，一切工具可用性判定以实际调用为唯一判据（检索穷举不构成证据，subagent 自报工具缺失前须实际调用实证），主会话复核失败重派一次、仍败回退并回报所测环境，反例清单两例（派发工具与 Subagent 文件工具均原生可用、不进 ToolSearch 延迟索引）；init 与升级的并行生成回退判定同款实证化

### sdd v2.7.0

#### 新增

- intake 文档受理：`/sdd-intake` 输入扩展为一至多份文档（路径或粘贴，体裁不透明），拆解映射经确认后批量落位（判据不能少、不能多），含糊 P 落 exploring 自然探索，存量对账轻按需触发；材料严格消费，映射确认完毕即无用（不冻结、不收编、不入库，删留归用户），I 条目记产物统计一行，未覆盖与暂缓默认落构想池

### sdd v2.6.0

#### 新增

- 自动化验证体系：AC 契约化（spec 验收标准表格化，验证方式绑定验证命令或人工，auto 模式全部 AC 绑定方许定稿）、runtime 验证命令区（名称 × 命令 × 类别 × 范围，登记闸门增测试框架与配置类目并加升级存量补记）与治理配置区（`Acceptance mode` 缺省 auto、`Verification retry limit` 缺省 3，经 `/sdd-config` 查看 / 切换）、证据制度（逐 AC 用例指认与摘要留档，映射失败按验证失败处理）、自动验收流水（auto 验证全绿自动走 accept 链无需发起，重试超限停驻上报，manual 模式经旁通阀 `/sdd-accept` 放行）、init 询问增验证模式（默认 auto）

## [1.6.0] - 2026-10-05

### sdd v2.5.0

#### 新增

- 验收环节条件化：验收清单表格 AC 逐条标注验证方式，自动验证（简报范围为提案全部任务清单的由承接 subagent 执行并回报，单个 Task 或不使用并行推进的由主会话执行），失败自动修复重验、反复未果上报用户，UI 交互类由用户人工操作；纯自动提案全绿后直接提示验收；列「人工测试步骤」更名「验证步骤」

## [1.5.0] - 2026-10-04

### sdd v2.4.0

#### 新增

- 版本格式选型提前至 init：询问表新增版本格式（CalVer 验收日或 SemVer；交付型惯用 CalVer，库 / 产品惯用 SemVer，默认 SemVer），登记于 runtime「路径、ID 与工程约定」节；升级回读扩为四字段，版本格式回读不到时维持首个 tag 前询问的旧行为，accept 收尾不再插问

### sdd v2.3.0

#### 新增

- 目标项目 CHANGELOG 规则重制为 Keep a Changelog 基准：常驻 `[Unreleased]` 节在实现期累积显著变化（随 Task 完成记入），accept 经三源核对后更名为版本节；分类扩为 Keep a Changelog 六类（新增 / 变更 / 弃用 / 移除 / 修复 / 安全）；尾部链接区按项目远程生成 diff 链接；full 与 slim 宪法规则一致

## [1.5.0] - 2026-10-04

### sdd v2.0.1

#### 新增

- slim 验收（sdd-accept）打发布 tag：验收通过时于当前分支 HEAD 打 annotated tag，发布语义与 full 对齐（standalone 恒落外层项目仓；升 full 版时 slim 时期 tag 原样保留续写，版本格式已定型不重复询问）

### sdd v2.1.0

#### 新增

- 验收（sdd-accept）联动 `CHANGELOG.md`：验收收尾、打 tag 之前增补项目根 `CHANGELOG.md`（不存在则创建，含 Keep a Changelog 风格说明头）；条目范围为本次 tag 与上一 tag 之间，内容三源锚定（accepted 提案 spec「范围内」、INDEX 提案行、区间 git log 提交主题，含直接落主干的维护修复），分四类，不含治理 ID；standalone 治理提交落外层仓，用中性 message
- 发布 tag message 改取本次 `CHANGELOG.md` 条目首行，与 changelog 永远同源
- 提交兜底 hook 辖区纳入 `CHANGELOG.md`

### sdd v2.1.1

#### 修复

- test 串行：全流程至多一个 P 持有 test 分支；验收位被占用时全任务 done 的 P 留在 implementing 等待（worktree 与 dev 分支保留），待在途 test accept 后再推进
- 冲突归属：全任务 done 从当前 main 切 test 合并 dev，冲突一律在 test 解决；删「长寿命分支定期同步主干」
- 验收期冻结：test 切出至 accept 期间 main 代码不前进（治理文档主干直写照旧），一切修复（含不进 Proposal 的维护性修复）落在当前 test，随本 P accept 一并进 main

### sdd v2.1.2

#### 变更

- 项目入口骨架（`CLAUDE.md` / `AGENTS.md`）删去智能体协作声明行：入口文件自解释，公开面按最小化收拢

### sdd v2.1.3

#### 新增

- mdLint 检查：行内代码内出现治理 ID 报 warning，执法 ID 禁包规则；检查集限于书写形态，内容治理不入检查集

#### 变更

- 书写判据加固：治理 ID 一律裸写、禁入行内代码（废止旧「ID 用行内代码包裹」条款）；文件名无论单独、带路径或以 `.` 开头一律包裹；键名组合（如 `Ctrl+C`）必包；链接地址裸写交渲染器自动链接；单词化的动作、配置与产品指称视同术语

### sdd v2.1.4

#### 修复

- 并行派发误报防护：派发入口或工具检索不到不构成不支持的证据，降级串行须以实际派发调用失败为准并回报注明所测环境；附已实证案例（Agent 工具是 Claude Code 核心工具，不进延迟工具索引）；删除派发承载机制的旧环境快照括注（机制细节归实证层）

### sdd v2.2.0

#### 新增

- 登记闸门：提交首次涉及未覆盖的工具链工件类（依赖清单、构建配置、迁移 SQL、语言脚本等）时启动，主会话给出候选工具建议、由用户选定并登记或扩展提交前校验命令，执行通过后方可提交；凡入库的工具链其 lint 与 format 必配，闸门无跳过，避免 SQL 迁移等存量格式割裂

## [1.4.0] - 2026-09-26

### sdd v1.0.2

#### 新增

- 验收清单表格定式：AC、验收标准、证据、人工测试步骤、结论五列；验收标准与 spec 逐字一致，会话输出，验收通过后整表追加 journal 作为验收记录

#### 变更

- 验收（sdd-accept）动作链显式化：主工作区先检出 main，合并 test 入 main 后再写治理文档（slim 同构去分支）

#### 修复

- 验收语义修正：未全过不置 accepted，Task 保持 done，删「回对应 Task 修正」及连带禁令；验收期缺陷属修复，提交 footer 记 `Fixes` 回链

### sdd v2.0.0

#### 新增

- 治理形态体系：inline（内联，随项目仓，默认）与 standalone（独立，单独治理仓）双形态，与 edition 正交，随初始化（sdd-init）一并选定且此后不可切换；既有低版本安装一律视为 inline
- standalone 零痕迹配套：`CLAUDE.local.md` 指针、info/exclude 六行排除清单、内层仓与内层 hook、项目仓提交无痕化（内层仓为纯文档仓，不设专门条款）
- 升级模式支持形态判定与 2.0.0 一次性迁移（内容无损，回报列清单）

#### 变更

- 目录结构统一：`CLAUDE.md` 与 `AGENTS.md` 改为项目骨架，治理运行态移入 `sdd/runtime/`（`claude.md`、`opencode.md`），OpenCode 经 `opencode.json` instructions 接入
- 脱敏按形态分级：inline footer 治理引用照记，standalone 项目仓无痕化

## [1.3.1] - 2026-09-20

### sdd v1.0.1

#### 修复

- 治理引用关键词修正：Task 完成记 `Closes: T-XXX`、验收通过（sdd-accept）记 `Closes: P-XXX`，`Fixes` 限于验收期缺陷修复，非定稿提交记 `Refs`；Task 完成只记代码侧提交，主干治理提交不重复记；footer 区可并存项目自有 trailer，也可有多个 trailer

## [1.3.0] - 2026-09-20

### sdd v1.0.0

#### 新增

- Git 工作流三分支拓扑：dev 开发、test 验收、main 发布
- 提交信息治理引用规则：治理 ID 移入 footer trailer 区

#### 修复

- worktree 目录名改用标题 slug，不再含治理 ID
- 验收措辞归位：全部 Task done 先提示人工测试，测试通过后验收（sdd-accept）
- 实现推进（sdd-start）参数语义定为 P-XXX 批量、T-XXX 单个、缺省取下一个 todo

#### 变更

- 措辞与标点调整：对账改校准、意向改构想、清理破折号

## [1.2.0] - 2026-09-20

### sdd v0.2.0

#### 新增

- slim / full 双 edition 体系：初始化（sdd-init）选档生成，slim 为精简真子集、单向可升；VERSION 格式改为 version+edition，新增 slim 逐字规格与模板
- 重跑对账路由：按签名集路由至校准或升级，初始化默认 edition 取 slim
- slim 受理提案（sdd-intake）后增探索定稿软门，禁探索性 Task

#### 修复

- 实现推进（sdd-start）语义修订：恢复实现推进的原义、支持派发与 T 指定；slim 命令分界重划，拆任务（sdd-split）并入受理提案（sdd-intake）
- 验收项语义归位：Task 详情去验收字段，全部 done 后才列 AC 清单
- slim rejected 行补实现代码处置显式条款（留原地由 git 历史兜底）

#### 变更

- R 规则与治理不变式改为 bullet 列表（diff 友好）；edition 判据措辞软化为建议性参考

## [1.1.0] - 2026-09-19

### sdd v0.1.0

#### 新增

- 环境重建显式化：新主机 clone 后 pre-commit 必缺，重跑初始化（sdd-init）即转升级模式补装

#### 变更

- 版本标记更名：`sdd/.version` 改为 `sdd/VERSION`（可见化、归入大写文档族；0.1.0 无安装存量，不设旧名兼容条款）
- `CLAUDE.md` 补记仓库 tag 版本约定（tag = 仓库版本，message 列插件版本）

## [1.0.0] - 2026-09-13

### sdd v0.1.0

#### 新增

- 初始发布：marketplace `star-plugins` 与插件 `sdd`；初始化（sdd-init）在目标项目生成整套 SDD 治理体系，适配 OpenCode，并安装 pre-commit 提交兜底 hook（mdLint 机械校验）
