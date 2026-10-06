# 更新日志

本仓发布以 tag 为版本，每个版本列出当次包含的 sdd 插件版本节点。格式参照 Keep a Changelog，条目分「新增 / 变更 / 修复 / 移除」四类，新版本在上。

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
