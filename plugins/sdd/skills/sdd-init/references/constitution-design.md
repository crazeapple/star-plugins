# 治理体系核心设计（生成 `CONSTITUTION.md` 的逐字规格源）

> 宪法文件以本文件为唯一规格源，生成时逐字复制。

宪法文件 = `# <项目名> SDD 治理宪法` + 本文件全部小节逐字（受理与分流、构想池、自治边界为正文节；并行开发为可选节）+ 末尾生效日期（`date +%F`）。

## 层级与分区

- 三层实体：**Initiative（I-XXX，总纲）**，模糊需求的产品层澄清与路线图，不进状态机；**Proposal（P-XXX）**，可独立验收的开发单元（基础件或功能块），真正的开发循环从这里开始；**Task（T-XXX，可数十个、可分组）**，design 任务清单内，禁止单独建文件。
- Proposal 粒度：必须是一个可独立验收的开发单元，禁止以产品版本形态立项（如「XX 第一版/首版」标题）；产品级、多交付物或模糊需求先入构想池拆解为总纲，再拆出 Proposal；两级拆分（I 拆 P、P 拆 T）不跨层。
- 受理两路：单交付物需求由 `/sdd-intake` 直接发 P（无 source）；多交付物或模糊需求先入 `INITIATIVE.md` 立 I，拆解后发 P（frontmatter `source: I-XXX`）。
- 分区治理：`sdd/exploring/`（探索区，格式宽松，含探索底稿 `P-XXX.md` 与 `journal.md`：底稿自提案创建起持续落盘探索与讨论过程，存活至验收通过或 rejected 终结，定稿不冻结）与 `sdd/specs/`（稳定区，格式严格、变更留痕，每提案一目录：`spec.md` 与 `design.md`）物理分离；修正隔离在 `amendments/` 与构想池；归档只从稳定区取材。
- **探索档案 `journal.md`**：项目内永久档案（不入归档四产物），按提案分节追加，即 `## P-XXX <标题>` + 状态轨迹行 + 底稿除 frontmatter 外正文原样；只追加与原位标注、不重写历史。开发中新情况的探索讨论过程，属当前提案范围内且形成新 Task 的，按主题补录底稿相应小节（不必然追加于末尾）；结论写 spec（changelog + version），过程写底稿。验收通过或 rejected 终结时底稿整稿入档后删除，on-hold 底稿留原地。
- **不预建**运行态目录：exploring/、specs/、`journal.md` 均动态形成；`INITIATIVE.md` 与 `amendments/amend.md` 由初始化生成。

## 权威源、ID 与日期

- INDEX 是 Proposal 状态**唯一权威源**，状态变更即时同步（操作即同步，不攒批）；`INITIATIVE.md` 是构想唯一记录；Task 状态唯一权威 = design 任务表；规格版本唯一维护处 = spec frontmatter `version`。
- I/P/T/A 四套编号各自全局递增，**永不复用、永不重排**（rejected 也占号）；P/T 发号统一在 INDEX 顶部计数器，I 号计数器位于 `INITIATIVE.md` 顶部，A 号计数器位于 `amendments/amend.md` 顶部；取号后立即递增写回。
- **日期规则**：治理文档一切日期唯一源 = 执行写入的会话所在机器的系统日期（本地时区）；写入前必须以 `date +%F`（或等价）实取；禁止凭记忆或上下文推断；粒度 YYYY-MM-DD。

## 状态机（禁止跳跃）

- Proposal：`exploring → specified → implementing → verifying → accepted`；旁路 `on-hold`（任意态可入可回，排队/搁置两用）、`rejected`（终态，INDEX 备注列写原因）。
- Task：`todo / doing / blocked / done / dropped`（done、dropped 为终态；doing 即锁定，禁重复派发）；design：`draft → finalized`。
- **代码与 Task 绑定**：项目功能实现代码必须挂在 design 任务清单的具体 Task 上；Task 未拆分（exploring/specified）禁止写实现代码，仅产出探索与规格文档；代码随 Task 执行写入；验收未过的缺陷修复提交按 footer 规则记 `Fixes: T-XXX` 回链 Task（standalone 形态项目仓无痕化不记 footer，改以 design 任务详情回填关联）。

## 受理与分流

- **维护/需求分类三问**：① 行为变化？（新能力/改变对外行为 = 需求；恢复既定或不改变 = 维护）② 方案空间？（存在真实选择 = 需求；路径唯一 = 维护）③ AC 自明性？（需协商定义 = 需求；自明 = 维护）。任一命中需求特征即立项；三问全维护 → 直接做，不立项。
- 分类四保险：**默认偏维护**（判不准一律按维护）；**停损升级**（维护中冒出方案选择或范围膨胀 → 当场停、补立项）；**口令优先**（分类仅为建议，用户一句终局）；**amendments 旁路**（维护暴露决策/设计错误 → 走 A-XXX）。例子锚点：改按钮颜色、修 typo、升依赖 = 维护；国际化、暗色主题、OpenAPI 文档 = 需求（XS 级）。
- **单/多交付物三问**：① AC 可写性（现在就能写出 1-3 条可核对的验收标准吗？）② 边界可划性（范围内外现在就能划清吗？）③ 交付物同质性（单一功能块，还是天然含多个异质交付物？）≥2 问指向「要拆」→ 入构想池；否则直接发 P。
- 同类重复不算异质（「给 10 个字段加校验」是一个 P 的 10 个 Task）；拿不准时兜底一问用户：「想一口气做完，还是先立框架分期做？」
- **误入池出口**：池内拆解后发现实为单交付物 → 关闭 I 条目，直接发 P（无 source）；直接 P 发现要拆 → 探索产物回填构想池升格。判错可恢复，均非事故。
- **判定示例**：用户登录功能，大功能但复杂性全在工程层（认证选型），产品结构上是一块，单交付物，直接发 P；完整账号体系（个人/企业、SSO、组织权限），产品级构想需路线图，入池立 I 拆解。

## 状态转换 × 文档同步矩阵

| 转换 | 必做操作 |
|---|---|
| intake 判定单交付物 →exploring | 模板建 `exploring/P-XXX.md` + INDEX 加行 |
| intake 判定多交付物 →构想池 | `INITIATIVE.md` 立 I 条目（原文保留 + 路线图） |
| I 拆出发号 →exploring | 模板建 `exploring/P-XXX.md`（frontmatter `source: I-XXX`）+ INDEX 加行 |
| exploring→specified（/sdd-finalize） | 建规格（被否备选录入否决记录）+ 底稿保留至验收 + INDEX 更新 |
| specified→implementing（/sdd-split） | 建 design 骨架 + 任务入清单 + 切 `.worktree/<标题 slug>` worktree（分支 `dev/<标题 slug>`） + INDEX 更新 |
| 任一 Task 状态变化 | 更新 design 任务表 + 任务详情小节回填 + 显著变化记入 CHANGELOG `[Unreleased]` |
| 全任务 done →verifying | test 串行检查（他 P 持有 test 分支则本次转换挂起：P 留在 implementing，任务表保持全 done，worktree 与 dev 分支保留，待其 accept 后重走本行）+ 从当前 main 切出 `test/<标题 slug>` 合并 `dev/<标题 slug>`（冲突一律在 test 解决；删除 worktree 与 dev 分支）+ 交付 hash 记入 design + INDEX 置 verifying + 列出验收清单表格（五列：AC / 验收标准 / 证据 / 验证步骤 / 结论；验收标准与 spec 逐字一致，会话输出不落盘）+ 进入验证（主工作区检出 test；已绑定命令的 AC 由登记命令自动验证，简报范围为提案全部任务清单的由承接该简报的 subagent 执行并回报，否则由主会话执行；`Acceptance mode` = manual 时 UI 类用户人工操作；证据逐 AC 指认（验证命令名 · 用例指认 · 输出摘要），指认不出覆盖用例即映射失败按验证失败处理；失败自动修复重验，重试累计达 `Verification retry limit`（缺省 3）仍未全绿即停驻，P 留 verifying、验收位留驻并上报）；`Acceptance mode` = auto 全绿即自动走 verifying→accepted 行（无需发起），manual 模式全绿且无人工类 AC 提示用户可发起 /sdd-accept |
| verifying→accepted（/sdd-accept；`Acceptance mode` = auto 时验证全绿自动触发，无需发起） | AC 逐条**以实际证据**核对验收清单表格（结论通过置 ✅；未全过不置 accepted，Task 保持 done）+ 全过后主工作区检出 main + 合并 `test/<标题 slug>` → main（发布）+ design 置 finalized + 底稿正文追加 journal 后删除 `P-XXX.md` + 通过的验收清单表格追加 journal + INDEX 更新 + CHANGELOG 三源核对补全 `[Unreleased]` 并更名为 `[版本] - 验收日`，其上新建空 `[Unreleased]`（六类、不含治理 ID；standalone 落外层中性 message）+ 治理提交（standalone 经 `git -C sdd` 落内层仓）后打 tag（永远打在外层项目仓）+ 删除 test 分支 + 完成回报固定建议「回看需求组拆下一个」 |
| I 完结 | 组内全部 P accepted → I 条目标完结（归档时并入 `requirements.md` 后移除） |
| →on-hold / rejected | INDEX 改状态 + journal 追加处置行（rejected 须写原因）；rejected 底稿整稿入档（标注 rejected）后删除，on-hold 底稿留原地；rejected 分环节清理分支：未建分支（exploring / specified）仅删文档，implementing 删 worktree 与 `dev/<标题 slug>`，verifying 删 `test/<标题 slug>`（main 零沾染）；on-hold worktree 与分支挂起保留 |
| 定稿后需求变更 | 规格正文 + changelog + version 递增（v1.0 → v1.1）+ 受影响 Task 评估，禁静默覆盖 |
| 归档（/sdd-archive） | INDEX 置「已归档 + 日期」+ 四产物 + 完结 I 条目并入 `requirements.md` + sdd 全区只读 |

- **CHANGELOG**：项目根 `CHANGELOG.md`（公开文件），格式以 Keep a Changelog 为基准。不存在则创建：H1 `# 更新日志`、中文导语（记录本项目所有显著变化，格式基于 Keep a Changelog）与常驻 `## [Unreleased]` 节。实现期的显著变化由主会话随 Task 完成记入 `[Unreleased]`（用户语言，一行一条）。accept 收尾、打 tag 之前：以三源（accepted 提案 spec「范围内」、INDEX 提案行、区间 git log 含直接落主干的维护修复）核对补全 `[Unreleased]`，禁凭空杜撰，随后将 `[Unreleased]` 更名为 `[版本] - 验收日`（版本取本次 tag，日期 ISO 8601），并在其上新建空 `[Unreleased]`。分类六类「新增 / 变更 / 弃用 / 移除 / 修复 / 安全」（对应 Keep a Changelog 六类），条目用 `-` 列表。统一不含治理 ID 与治理词汇，说用户语言，edition 与形态无关。定稿随 accept 完成回报展示，用户守门可改。文件尾部设链接区：每版本一条 diff 对比链接，自项目远程推导，无远程则省略。落仓：inline 随治理提交，standalone 为外层公开文件随中性 message 提交；辖区入外层 hook。

## 会话微流程 R1-R10（写入宪法）

- **R1** 冷启动读 CONSTITUTION → INDEX → INITIATIVE，输出状态摘要（含构想池概览：活跃 I 数、待梳理条目、未立项里程碑）
- **R2** 新想法当场分类（维护/需求三问）：维护直接做并回报；需求一律经 /sdd-intake 受理，单交付物直接发号，多交付物先落构想池；当前工作永不因新想法自动中断
- **R3** 探索期自顶向下、先发散后收敛、逐层留痕（实时写入底稿，用户给出内容同样落盘；过程全程落盘底稿，结论演进走 spec changelog）
- **R4** 被否备选禁删，记入提案「否决记录」，留「方案 + 一句话原因」
- **R5** 实现中新需求：小则 Task 内消化回填，改验收标准则停手上报由用户定
- **R6** 更新任务表 + 回填 design；全任务 done 列出验收清单表格（由 spec 验收标准表派生，验证步骤按 spec 验证方式分派）并进入验证；已绑定命令的 AC 由登记命令自动验证：简报范围为提案全部任务清单的，由承接该简报的 subagent 执行并回报；简报为单个 Task（任务级并发）或不使用并行推进的，由主会话执行；证据逐 AC 指认（验证命令名 · 用例指认 · 输出摘要），指认不出覆盖用例即映射失败按验证失败处理。失败自动修复重验，重试累计达治理配置 `Verification retry limit`（缺省 3）仍未全绿即停驻（P 留 verifying、验收位留驻并上报）；`Acceptance mode` = auto 全绿即自动走 accept 链，manual 模式全绿且无人工类 AC 提示用户可验收
- **R7** 关键节点（拆任务/定稿/归档）显式建议对应命令保人工确认，验收节点限 `Acceptance mode` = manual（显式建议 /sdd-accept 保人工确认；auto 模式验证全绿自动走 accept 链，无需发起）；accept 完成回报固定建议回看需求组（auto 模式随自动验收回报）
- **R8** 不改 templates/，tools/ 仅随 Markdown 规范演进修改；稳定区禁自由格式；归档后只读；写/改任何 sdd 文档后必须运行 mdLint，零 error 方可回报完成（warning 逐条确认或忽略）
- **R9** 跨周期修正禁只改代码，走 amendments/
- **R10** 分支开发主干发布：split 从 main 切 `dev/<标题 slug>` 并建 worktree 开发（分支名不含治理 ID 与治理文件名），代码在分支、治理文档只在主干由主会话写，test / dev 检出中 sdd/ 只读；分支提交以 Task 为界、Task 完成即提交；test 串行：全流程同时至多一个 P 持有 test 分支，全任务 done 而他 P 持有 test 时留在 implementing 等待（任务表保持全 done，worktree 与 dev 分支保留），待其 accept 后再行 verifying 转换；全任务 done 从当前 main 切 `test/<标题 slug>` 合并 dev 代码（冲突一律在 test 解决），删除 worktree 与 dev 分支，列验收清单表格交主工作区检出 test 验证（已绑定命令的 AC 由登记命令自动验证，简报范围为提案全部任务清单的，由承接该简报的 subagent 执行并回报，否则由主会话执行，manual 模式 UI 类用户人工操作，失败自动修复重验，重试累计达 `Verification retry limit`（缺省 3）仍未全绿即停驻并上报）；主干冻结：验收期（test 切出至 accept）内 main 代码不前进（治理文档主干直写照旧），一切修复（无论缺陷源自哪个 P 的范围，含不进 Proposal 的维护性修复）都落在当前 `test/<标题 slug>`，随本 P accept 一并进 main，验收期外维护照旧直接落 main；accept 时 AC 逐条以实际证据核对填入验收清单表格（未全过不置 accepted，Task 保持 done）→ 主工作区检出 main → 合并 test → main 发布 → 治理提交 → 打 annotated tag（版本格式取工程约定节登记，信息取本次 CHANGELOG 条目首行）→ 删 test 分支；rejected 分环节清理（未建分支删文档 / implementing 删 dev 与 worktree / verifying 删 test），main 零沾染，on-hold 挂起保留；提交信息 title 与 body 不含治理 ID；需要引用治理实体时，在 footer 区（body 后空一行、逐行）按 trailer 惯例记，关键词随本提交对实体的作用而定，无引用则不写（Task 完成 → `Closes: T-XXX`，accept 验收提案 → `Closes: P-XXX`，验收阶段修复已完成 Task 的缺陷 → `Fixes: T-XXX`，一 Task 多提交时的非收尾提交等 → `Refs: T-XXX`）；开发过程中的自我修正不属修复语义，随所在 Task 完成提交记；Task 完成只记代码侧提交，主干治理提交不重复记；footer 区可并存项目自有 trailer，也可有多个 trailer；standalone 形态本段整体替换为「项目仓提交不含治理 ID、治理引用与 sdd 字样（无痕化），内层治理仓提交不受此限」；代码提交前须通过项目提交前校验（lint、format、测试等，以项目工程约定为准）。本次提交涉及工具链工件（依赖清单、构建配置、迁移 SQL、语言脚本、测试框架与配置等）且该类未登记覆盖时，登记闸门启动：主会话给出候选工具建议，由用户选定并登记（落 runtime 验证命令区）或扩展校验命令，执行通过后方可提交；凡入库的工具链，其 lint 与 format 必配，此为工程化要求，闸门无跳过，登记后随技术栈定型更新；push 永远手动。

## 自治边界（判断自动，动作守门；写入宪法）

| 层级 | 事项 |
|---|---|
| 自动执行，做完告知 | 维护/需求分类判断、维护直接做、新想法落池、三问执行、XS 产物极短化、R1 摘要、board 聚合、自动验收（`Acceptance mode` = auto，验证全绿则自动走 accept 链） |
| 判断 + 明示理由，可一句话推翻 | 建议立项、on-hold 排队建议 |
| 永远用户守门 | 发号（P）、授予 I、finalize、验收发起（`Acceptance mode` = manual）、停损升级、archive、决策反转入册（A）、写实现代码 |

## Markdown 书写规范（宪法此节以本节为唯一规格源；`mdlint.sh` 按此实现）

- **语法总则**：遵循 CommonMark/GFM 语法，结构符号一律半角（列表标记、链接括号、标题 `#`、表格 `|` 与 `-` 分隔行）；强调一律 `*` 禁 `_`；行内代码反引号与加粗 `**` 成对闭合- **混排层**：中文正文标点全角（，。：；？！、（）「」）且成对闭合；中文与英文/数字/半角符号之间加一个半角空格（× 表倍数时与数字紧贴，如「模板 ×4」），标点/代码边界处不加（按渲染后中英边界判断；强调与行内代码标记不构成边界）；中文正文引用标记只用「」或半角直引号 ""；半角引号等半角符号与中文相邻时，两侧须加空格；命令、路径、文件名（无论单独、带路径或以 `.` 开头）、键名组合、代码用行内代码包裹；片段含 `/`、`~`、`*`、`_`、`<`、`&`、`|` 任一字符的亦包裹；治理 ID（I-001 / P-001 / T-001 / A-001 形态）一律裸写，禁入行内代码；带 scheme 前缀的链接地址（http、https、ftp、mailto 等）裸写且优先于字符判据，交渲染器自动链接；其余片段一律裸写，单词化的动作、配置与产品指称视同术语；破折号「——」避免使用，解释性插入宁用「：」「，」「（）」或语言描述；同一句子内、同一层级不重复使用冒号（半角 `:` 与全角 `：` 同计，行首标签与 `type:` 前缀计入，括注内与表格字段除外）；commit message 与 tag message 同此规则；省略号「……」、空值占位单个 `—`（仅表格与字段）、范围号紧贴 `-`（`R1-R10`）、禁用 `–`；列表项短语结尾不加标点、整句加中文句号；表格单元格不加句号；专有名词保持原大小写（README、`CLAUDE.md`）；无序列表统一 `-`、有序列表统一 `1.`
- **语义层**：算式与维度一律紧凑（`1+2`、`3-2=1`、`4×5`、`4×4 矩阵`、`n×m`）；`+`、`-`、`=` 不机械检查（区间、复合词、散文等号合法）；× 连接中文两侧加空格（状态转换 × 文档同步）；倍数写「模板 ×4」；计数比一律 `/`（3/8），`×` 禁表计数比或分隔；流程用「→」；并列用「与/·」
- **校验**：`sh sdd/tools/mdlint.sh <文件或目录>`（POSIX sh + awk + perl，macOS 自带零依赖）。检查集按 AI 作者错误分布校准，限于书写形态，内容治理不入检查集。error：反引号或 `**` 行内不配对、全角圆括号/直角引号文件级不配对；warning：中英文粘连（剥离行内代码后）、无序列表标记非 `-`、表格行列数与表头不一致（GFM 会静默补空或丢弃）、行内代码内出现治理 ID（执法 ID 禁包规则）。检查豁免代码围栏；行内代码内容除治理 ID 检查外豁免。零 error 方可回报，warning 逐条确认或忽略。提交兜底：sdd-init 安装 `.git/hooks/pre-commit`（三端通用：Claude Code、OpenCode 与人工提交同受约束），staged 文件落于辖区（`sdd/` 下、`CLAUDE.md`、`CHANGELOG.md`、`.claude/commands/`、`AGENTS.md`、`.opencode/commands/`）时整体跑本工具，有 error 非零退出阻止提交；warning 不拦，工具缺失静默放行。standalone 形态另装 `sdd/.git/hooks/pre-commit` 内层变体（源 `scripts/pre-commit-inner.sh`，辖区 = 内层仓全部 staged `.md`），治理提交同受约束。

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

## 修正机制（amendments/，跨周期）

- **登记簿**：`amendments/amend.md`（初始化生成），条目式追加，只录**已完结提案（accepted 及之后）**实现后被推翻或替换的决策反转；活跃提案内的否决与修正留在提案自身文件（否决记录、关键决策表 + changelog）。决策反转归用户守门，AI 仅可建议。
- **条目格式**：`### A-XXX <标题>（YYYY-MM-DD）` 行 + `关联：P-XXX / T-XXX` 行（多关联「、」分隔，无关联省略该行）+ `状态：active | superseded by A-YYY` 行 + `**决策**`（一句话）、`**理由**`、`**影响范围**` 三个加粗标签段。被替换条目仅原位改状态行，其余内容不动；A 号永不复用。
- 跨周期替换四步：① 新建条目说明替换方案与原因 ② 旧条目原位改状态 superseded by 新 A ③ 更新受影响规格（升版 + changelog）与 design 关键决策表 ④ 评估 INDEX 中依赖该决策的其他提案。

## 构想池（`INITIATIVE.md`）

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

## 并行开发（可选节）

/sdd-start 默认单智能体一步到位；仅用户明确要求时切「派发-回收」两段式：主会话组装自包含任务简报派发（简报范围按需组装：单个 Task 或提案全部任务清单，对应任务级与提案级并行；均含验收标准与规格/设计节选）；回收逐条核验、统一更新。约束：sdd/ 文档只允许主会话写入，子智能体只读文档、写代码、对话回报，发现规格问题回报主会话走 R5。并行派发能力以实证判定：检索不到派发工具不构成环境不支持的证据（各环境派发机制不同，常驻工具未必进入检索索引），仅实际派发调用失败方可降级串行，并在回报注明失败事实与所测环境。已实证案例：Agent 工具是 Claude Code 核心工具，不进延迟工具索引，所以 ToolSearch 检索不到。

## 归档（/sdd-archive）

四产物：`requirements.md`（仅 accepted 项、剔 changelog/frontmatter、rejected 不出现，其信息由「范围外」章节承载，并含完结 I 条目内容作为需求来源章节）；`design.md`（整合全部 finalized design、剔任务表等过程内容）；`amendment-log.md`（整合全部修正案，按主题分组，保留完整 superseded 生命周期链）；`REUSE-GUIDE.md`（四步：归档时 AI 可按域或模块对 `requirements.md` 自由分组组织，无需预定义域枚举；在新项目安装 sdd 插件（marketplace `star-plugins`）并执行 `/sdd:sdd-init` 生成治理体系 → 逐提案比对差异（采纳/调整/排除，排除必须写入新项目修正记录说明原因）→ 参照旧设计制新设计（冲突时优先参考 superseded 链防重蹈覆辙）→ 正常推进）。
