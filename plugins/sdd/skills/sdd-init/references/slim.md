# slim 版生成、对账与升 full 版（edition 逐字规格源）

> 本文件是 slim edition 的唯一规格源（设计决策见仓库 `docs/` 目录的 `DESIGN-SDD.md` §十七）；slim = full 的真子集，full 侧规格（constitution-design / command-specs / upgrade / opencode-adapter）一字不改。edition 分叉只发生在 SKILL.md dispatch 层。

## 一、生成清单（5 治理文件 + 1 治理工具 + 1 版本标记 + 4 命令 + 7 适配 = 18 文件）

```
<项目根>/
├── CLAUDE.md                      # 会话入口：路标 + 硬规则摘要（slim 骨架，见 §四）
├── AGENTS.md                      # OpenCode 入口：@ 引用 CLAUDE.md（单一事实源）
├── .gitignore                     # 本地文件不入库：*.local.*
├── .claude/commands/              # 4 命令，sdd- 前缀（命令唯一源）
│   ├── sdd-intake.md  sdd-start.md
│   ├── sdd-board.md  sdd-accept.md
├── .opencode/
│   ├── opencode.json              # OpenCode 共享配置（lsp: true）
│   └── commands/                  # 4 命令存根（@ 引用 .claude/commands/ 同名文件）
└── sdd/
    ├── VERSION                    # 版本标记：`X.Y.Z+slim`（升级对账的回报基线，非治理文档）
    ├── CONSTITUTION.md            # SDD 治理宪法（slim 骨架，见 §二）
    ├── INDEX.md                   # 登记簿：提案状态唯一权威 + P/T 计数器 + 意向小节（见 §三）
    ├── templates/  spec.md  design.md   # 纯复制自 templates/slim/
    └── tools/
        └── mdlint.sh              # 治理工具（非治理文档）：Markdown 规范校验
```

- 运行态目录不预建：`sdd/specs/`、`sdd/exploring/`（含 journal.md）随首个 P 动态形成。
- 另生成不入库的 `.git/hooks/pre-commit`（R 提交兜底，契约见 §二「Markdown 书写规范」校验节；不入 18 文件清单）。
- OpenCode 适配 ×7 的逐字规格与机制依据照读 `references/opencode-adapter.md`（与 edition 无关），仅存根数量为 4、对应本文件 §五命令表。

## 二、CONSTITUTION.md 生成骨架（slim，逐字）

宪法文件 = `# <项目名> SDD 治理宪法` + 溯源行（`> sdd@star-plugins <版本> · edition：slim`，版本与全限定名取自安装时插件清单）+ 本节以下各小节逐字 + 末尾生效日期（`date +%F`）。

## 层级与分区

- 两层实体：**Proposal（P-XXX）**——需求受理单元，需求即 P，大小不设限，体量由任务表承载；**Task（T-XXX，全局编号）**——design 任务清单内的可执行单元，禁止单独建文件。
- 受理两路：想法明确、能写出可核对验收标准 → `/sdd-intake` 直接发 P；尚模糊 → 记入 INDEX「意向」小节单行（无编号），成熟后受理为 P。
- 分区治理：`sdd/specs/`（稳定区，格式严格、变更留痕，每提案一目录：spec.md 与 design.md）与 `sdd/exploring/`（探索区，含 journal.md——探索与讨论过程实时直写对应 `## P-XXX` 节；提案存活期间该节为工作区，accepted / rejected 后冻结为永久档案，只追加不重写）物理分离。
- **不预建**运行态目录：specs/ 与 exploring/ 随首个 P 动态形成。

## 权威源、ID 与日期

- INDEX 是 Proposal 状态**唯一权威源**，状态变更即时同步（操作即同步，不攒批）；INDEX「意向」小节是念头唯一记录；Task 状态唯一权威 = design 任务表；规格版本唯一维护处 = spec frontmatter `version`。
- P / T 两套编号各自全局递增，**永不复用、永不重排**（rejected 也占号）；发号计数器位于 INDEX 顶部；取号后立即递增写回。
- **日期规则**：治理文档一切日期唯一源 = 执行写入的会话所在机器的系统日期（本地时区）；写入前必须以 `date +%F`（或等价）实取；禁止凭记忆或上下文推断；粒度 YYYY-MM-DD。

## 状态机（禁止跳跃）

- Proposal：`exploring → implementing → accepted`；旁路 `on-hold`（任意态可入可回，排队/搁置两用）、`rejected`（终态，INDEX 备注列写原因）。
- **exploring 态职责**：探索、讨论与规格填实——过程直写 journal 对应 P 节，结论回填 spec（AC 写实、范围内外划清）与 design「设计要点」（方案与关键选型落定）；受理对话若已聊透，此态可为零时长。`/sdd-intake` 可重入：对在途 P 继续探索澄清，直至无疑虑。
- **implementing 进入门槛（/sdd-intake 拆分前软门）**：AC 全部可核对、范围内外明确、方案要点与关键选型已定、无疑虑——任一不满足则继续探索对话，不拆分、状态不动。
- Task：`todo / doing / blocked / done / dropped`（转换 `todo → doing → blocked → todo / done`；done、dropped 为终态；doing 即锁定，禁重复派发）。design：`draft → finalized`。
- **Task 质量要求**：Task 必须是具体、可直接执行的实现单元；探索、调研、决策类事项记录于 journal 与关键决策表，禁止立为 Task。
- **代码与 Task 绑定**：项目功能实现代码必须挂在 design 任务清单的具体 Task 上；Task 未拆分（exploring）禁止写实现代码，仅产出规格与探索记录；代码随 Task 执行写入，验收未过回对应 Task 修正，禁止绕过 Task 直接改码。

## 受理与分流

- **一问分类**：这次改动会改变外部行为或新增能力吗？会 → 需求，受理为 P；不会（恢复既定、修 typo、升依赖等）→ 维护，直接做并回报。
- 分类保险：**默认偏维护**（判不准一律按维护）；**停损升级**（维护中冒出方案选择或范围膨胀 → 当场停、补立 P）；**口令优先**（分类仅为建议，用户一句终局）。
- **念头与需求**：想法明确、能写出可核对验收标准 → 受理为 P；尚模糊 → INDEX「意向」小节记一行，成熟后受理为 P、原行移除。
- **定稿后需求变更**：spec 正文 + changelog + version 递增（v1.0 → v1.1）+ 受影响 Task 评估，禁静默覆盖。

## 状态转换 × 文档同步矩阵

| 转换 | 必做操作 |
|---|---|
| intake 受理为 P →exploring | 建 `specs/P-XXX/`（spec.md 与 design.md 骨架）+ journal 开节 + INDEX 加行 |
| intake 重入（在途 P） | 继续探索澄清（journal 直写）+ spec / design 填实，状态不变 |
| 念头登记 | INDEX「意向」小节加行（非状态转换，不占号） |
| 意向成熟受理为 P | 发 P 号建档，原意向行移除 |
| exploring→implementing（/sdd-intake 拆分完成时） | 定稿软门自查（对话内：AC 填实、方案已定、无疑虑）→ 任务表拆分（任务须具体可执行，禁探索性任务）+ INDEX 更新 |
| 任一 Task 状态变化（/sdd-start） | 仅更新 design 任务表 + 任务详情小节回填 |
| 全任务 done | INDEX 更新 + 列出全部验收项（AC 清单）+ 显式建议 /sdd-accept |
| implementing→accepted（/sdd-accept） | AC 逐条**以实际证据**核对（未全过不置 accepted，回对应 Task 修正）+ design 置 finalized + journal 节冻结 + INDEX 更新 |
| →on-hold / rejected | INDEX 改状态；rejected 须写原因，journal 节冻结并标注 |
| 定稿后需求变更 | spec 正文 + changelog + version 递增 + 受影响 Task 评估，禁静默覆盖 |

## 会话微流程 R1-R7（写入宪法）

- **R1** 冷启动读 CONSTITUTION → INDEX，输出状态摘要（含意向条目数与在途提案）
- **R2** 新想法当场一问分类：维护直接做并回报；需求一律经 /sdd-intake 受理为 P，模糊念头落意向小节；当前工作永不因新想法自动中断
- **R3** 探索与讨论实时直写 exploring/journal.md 对应 P 节（只追加、不重写历史），结论演进走 spec changelog
- **R4** 被否备选禁删，记入 design 关键决策表，留「方案 + 一句话原因」
- **R5** 实现中新需求：小则 Task 内消化回填，改验收标准则停手上报由用户定
- **R6** 更新任务表 + 回填 design；全任务 done 列出全部验收项（AC 清单）并建议 /sdd-accept
- **R7** 验收节点显式建议 /sdd-accept 保人工确认；push 永远手动；代码提交前须通过项目提交前校验（lint、format、测试等，以项目工程约定为准）。

## 自治边界（判断自动，动作守门；写入宪法）

| 层级 | 事项 |
|---|---|
| 自动执行，做完告知 | 一问分类判断、维护直接做、念头落意向、R1 摘要、board 聚合 |
| 判断 + 明示理由，可一句话推翻 | 建议立项、on-hold 排队建议 |
| 永远用户守门 | 发号（P）、accept、停损升级、写实现代码 |

## 意向（INDEX「意向」小节）

- 念头唯一记录；条目无编号，单行 `- <一句话>（YYYY-MM-DD 登记）`，随时可删除。
- 流转：成熟受理为 P（原行移除）；升级到 full 版时整节迁入 `sdd/INITIATIVE.md`，逐条获发 I 号。
- 插单：新念头落行不打断当前工作；不立刻做的 P 置 on-hold 排队。

## 并行开发（可选节）

`/sdd-start` 默认单智能体顺序推进（按任务表取 T）；仅用户明确要求时切「派发-回收」两段式：主会话组装自包含任务简报（任务 + 验收标准 + 规格 / 设计节选）派发，回收逐条核验、统一更新任务表。约束：`sdd/` 文档只允许主会话写入，子智能体只读文档、写代码、对话回报（做了什么 / 验收逐条结论 / 规格偏差走 R5 上报）；doing 即锁定，禁重复派发。

## Markdown 书写规范（宪法此节以本节为唯一规格源；mdlint.sh 按此实现）

- **语法总则**：遵循 CommonMark/GFM 语法，结构符号一律半角（列表标记、链接括号、标题 `#`、表格 `|` 与 `-` 分隔行）；强调一律 `*` 禁 `_`；行内代码反引号与加粗 `**` 成对闭合；标识符与含 `*`、`_`、`<`、`&`、`~`、`|` 的片段入行内代码
- **混排层**：中文正文标点全角（，。：；？！、（）「」——）且成对闭合；中文与英文/数字/半角符号之间加一个半角空格（× 表倍数时与数字紧贴，如「模板 ×4」），标点/代码边界处不加（按渲染后中英边界判断；强调与行内代码标记不构成边界）；中文正文引用标记只用「」或半角直引号 ""；半角引号等半角符号与中文相邻时，两侧须加空格；命令、路径、代码、ID（P-001/T-001）用行内代码包裹；破折号「——」、省略号「……」、空值占位单个 `—`（仅表格与字段）、范围号紧贴 `-`（`R1-R7`）、禁用 `–`；列表项短语结尾不加标点、整句加中文句号；表格单元格不加句号；专有名词保持原大小写（README、CLAUDE.md）；无序列表统一 `-`、有序列表统一 `1.`
- **语义层**：算式与维度一律紧凑（`1+2`、`3-2=1`、`4×5`、`4×4 矩阵`、`n×m`）；`+`、`-`、`=` 不机械检查（区间、复合词、散文等号合法）；× 连接中文两侧加空格（状态转换 × 文档同步）；倍数写「模板 ×4」；计数比一律 `/`（3/8），`×` 禁表计数比或分隔；流程用「→」；并列用「与/·」
- **校验**：`sh sdd/tools/mdlint.sh <文件或目录>`（POSIX sh + awk + perl，macOS 自带零依赖）。检查集按 AI 作者错误分布校准。error：反引号或 `**` 行内不配对、全角圆括号/直角引号文件级不配对；warning：中英文粘连（剥离行内代码后）、无序列表标记非 `-`、表格行列数与表头不一致（GFM 会静默补空或丢弃）。检查豁免代码围栏与行内代码内容。零 error 方可回报，warning 逐条确认或忽略。提交兜底：sdd-init 安装 `.git/hooks/pre-commit`（三端通用——Claude Code、OpenCode 与人工提交同受约束），staged 文件落于辖区（`sdd/` 下、`CLAUDE.md`、`.claude/commands/`、`AGENTS.md`、`.opencode/commands/`）时整体跑本工具，有 error 非零退出阻止提交；warning 不拦，工具缺失静默放行。

mdlint.sh 实现后必须以下列向量自测全过方可视为达标：

| 自测向量 | 预期 |
|---|---|
| 行内反引号单只不闭合 | error |
| 中文与英文直接粘连（剥离行内代码后） | warning |
| 上述任一情形位于代码围栏或行内代码内 | 豁免 |
| 「模板 ×4」倍数紧贴写法 | 无输出 |

pre-commit.sh 实现后必须以下列向量自测全过方可视为达标（临时仓库：置 `sdd/tools/mdlint.sh`、hook 装入 `.git/hooks/` 并加可执行位）：

| 自测向量 | 预期 |
|---|---|
| 无 staged 文件 | 静默退出 0 |
| staged 辖区 `.md` 含 error | 非零退出 + stderr 列出问题 |
| staged 辖区 `.md` 干净或仅 warning | 0 放行 |
| staged 辖区外 `.md` 含 error | 0 放行 |
| `sdd/tools/mdlint.sh` 缺失 | 静默退出 0 |

## 三、INDEX 生成骨架（slim）

```markdown
# 登记簿（INDEX）

> 项目状态：<一句话，由冷启动摘要与 board 更新>
> 计数器：next-P: 001
> 计数器：next-T: 001

## 提案总览

| ID | 标题 | 规模 | 状态 | 任务进度 | 规格版本 | 更新日期 | 备注 |
| --- | --- | --- | --- | --- | --- | --- | --- |

## 意向

（暂无念头；条目格式 `- <一句话>（YYYY-MM-DD）`，格式规则见 CONSTITUTION「意向」节）
```

规模列取值 S（≤5 任务）/ M（6-20）/ L（>20），未预判留空；列集与 full 版逐字同构，升级零迁移。

## 四、CLAUDE.md 生成骨架（slim，最后由主会话写）

章节顺序固定：标题 `# <项目名>` + 项目定位一句话（首行）→ **edition 行**（`sdd@star-plugins <版本> · edition：slim`）→ 需求层级（两层 Proposal / Task）→ 会话必读（CONSTITUTION → INDEX，冷启动摘要含意向条目数）→ 命令一览（表：命令 × 用途 ×4，表下注明调用即文件名形式 `/sdd-intake` 等，并补充说明：slim 无 finalize / split / archive——定稿并入 intake、拆任务随 design 任务表、不设归档）→ 硬规则 → 路径、ID 与工程约定（分区路径、P / T 发号、日期唯一源 `date +%F`、提交前校验命令或「无」）。硬规则（7 条）：

- ① INDEX 是状态唯一权威源（含「意向」小节），变更即时同步
- ② 新想法先一问分类：维护直接做；需求一律经 `/sdd-intake` 受理为 P
- ③ 定稿后需求变更留痕升版，禁静默覆盖
- ④ 被否备选记入 design 关键决策表，禁删漏记
- ⑤ 写改 sdd 文档后运行 mdLint，零 error 方可回报
- ⑥ 命令文件（`.claude/commands/*.md`）新增或删除后必须同步增删 `.opencode/commands/` 同名存根，`description` 变更须同步存根描述行，正文永不复制
- ⑦ 代码提交前通过项目提交前校验；push 永远手动

## 五、命令规格表（slim，4 命令；description 英文单源）

- 统一 `sdd-` 前缀；每命令正文必含：角色、前置检查、动作序列、完成回报格式，正文中文；frontmatter `description` 英文；均支持 `$ARGUMENTS`；写 sdd 文档的命令（intake / start / accept）完成回报前必须运行 mdLint 且零 error；命令与状态的对应关系以宪法「状态转换 × 文档同步矩阵」为唯一来源；**本表为 slim 版 description 与参数约定的唯一来源**（与 full 版 command-specs 各管各 edition），CLAUDE.md 命令一览表、各命令 frontmatter、`.opencode` 存根描述一律由此复制，禁止另编。

  | 命令 | description（英文，frontmatter 原样） | 触发时机 | $ARGUMENTS 约定 | 动作依据（矩阵） |
  |---|---|---|---|---|
  | sdd-intake | Capture a new requirement, or continue planning an in-flight proposal, until it is split into concrete tasks; vague ideas park in the INDEX intention list | 新念头与需求受理（含插单）、在途 P 继续规划 | 可选：需求 / 念头描述 / P-XXX（在途 P 重入） | 一问分类：维护直接做并结束；受理或重入 → 探索澄清 + 定稿软门 + 拆 T（exploring→implementing 行）；尚模糊 → 意向小节加行 |
  | sdd-start | Implement tasks from the design task list | 实现推进（默认顺序循环至全 done；可派发并行） | 可选：P-XXX / T-XXX（P-XXX 多 P 在途时消歧；T-XXX 指定先做某个 Task） | 推进模式：按任务表顺序取下一个 todo T（doing → 实现 → 回填实现记录 → done）循环至全 done，建议 /sdd-accept；T-XXX 指定则优先该 Task；用户明确要求并行时切派发-回收（见宪法「并行开发」节）；遇 blocked 暂停推进并回报；期间 R5 / R7 照常 |
  | sdd-board | Show proposal status overview | 查看状态（只读） | 可选：P-XXX | 无矩阵行：读 INDEX 输出摘要（首行自报 edition 与版本），不改任何文档 |
  | sdd-accept | Verify acceptance criteria and mark the proposal accepted | 全任务 done 后验收 | 必填：P-XXX | implementing→accepted 行；完成回报建议受理下一个需求 |

## 六、slim 模板（纯复制自 `templates/slim/`）

`sdd/templates/spec.md` 与 `sdd/templates/design.md` 纯复制自本技能 `templates/slim/` 同名文件（骨架即规格，P-XXX / T-XXX 为占位，建文件时替换为实际号）；任务表 4 列（任务 ID | 标题 | 状态 | 备注），关键决策表 4 列（决策 | 选项 | 选择 | 理由）；T 状态合法转换与详情小节格式见 CONSTITUTION「状态机」节。

## 七、验证与提交（slim 全新安装）

1. 失败处置总则同 SKILL.md「四、验证与回报」（失败修复后重跑全量验证，禁止带病提交）。
2. 18 文件齐全、结构正确、必填项已填（5 治理文件 + 1 治理工具 + 1 版本标记 + 4 命令 + 7 适配文件）；`sdd/VERSION` 内容 = 插件清单 `version` + `+slim`；`.git/hooks/pre-commit` 已生成且可执行（不入库、不占清单）。
3. 对全部生成文件运行 `sh sdd/tools/mdlint.sh sdd/ CLAUDE.md .claude/commands/ AGENTS.md .opencode/commands/`，零 error。
4. ID / 状态机 / 矩阵在 CONSTITUTION、INDEX、模板、4 命令间交叉一致。
5. `git check-ignore` 与 `opencode debug config` 同 SKILL.md 条款（4 个 sdd 命令全部被发现，description 与本文件 §五命令表逐字一致；opencode 未安装时跳过并在回报注明）。
6. git 提交两次、各自独立、显式列举路径、禁用 `git add -A` 与 `git add .`：第一次仅 11 清单文件（CLAUDE.md + INDEX + CONSTITUTION + VERSION + templates ×2 + mdlint + 命令 ×4），消息固定 `chore: 初始化 SDD 治理体系（slim 版：5 治理文件 + mdlint 工具 + 版本标记）`；第二次仅 7 适配文件（AGENTS.md + .gitignore + opencode.json + 存根 ×4），消息固定 `chore: 适配 OpenCode（AGENTS.md 入口 + 命令存根 @ 引用 + .opencode 共享配置）`；除清单文件与 hook 外禁止创建任何其他文件。
7. 最终回报：文件清单 + 两个 commit hash + mdLint 结论 + 各项验证结论 + 初始化耗时 + hook 安装结论 + 模式与版本 / edition 去向；冒烟默认不执行，待命 `/sdd-intake`。

## 八、slim 对账（同 edition 幂等重装）

触发：slim 签名集命中且用户未选择升级（单问题默认分支，见 SKILL.md dispatch 与 `references/upgrade.md` §一 edition 路由）。

- **对账范围（机械资产档）**：`sdd/tools/mdlint.sh`、`.git/hooks/pre-commit`（重装加可执行位）、`sdd/templates/` spec / design ×2、`.claude/commands/` ×4、`.opencode/opencode.json`、`.opencode/commands/` ×4——按 slim 规格纯复制覆盖；`.gitignore` 逐行补缺。
- **保护性写入**：`sdd/CONSTITUTION.md` 与 `CLAUDE.md` 按 slim 骨架重生成，项目字段（项目名 / 定位 / 提交前校验命令）回读保留，CONSTITUTION 生效日期保留原值。
- **禁触**：`sdd/INDEX.md`、`sdd/specs/`、`sdd/exploring/journal.md` 全部内容（INDEX 仅按锚点只读比对：next-P / next-T 标签在位 + 总览表表头列集一致 + 意向小节标题在位）。
- **版本标记**：`VERSION` 刷新为当前插件 `version + +slim`。
- **提交**：按实际变更显式列举分批（同款两批制），消息同 §七；零变更批次跳过并在回报注明。
- **回读**：项目名 ← `CLAUDE.md` 首行标题；项目定位 ← 首段定位句；提交前校验命令 ← 「路径、ID 与工程约定」节；回读不到才询问（唯一询问点），拒答按默认值生成并回报注明。
- **回报**：模式（slim 对账）+ 版本去向（`X → Y`）+ 覆盖清单 + 跳过批次 + commit hash + mdLint 结论 + 验证结论 + 耗时 + hook 重装结论。

## 九、升 full 版（slim → full，单向；本文件特有条款）

- **前置闸门**：INDEX 存在非终态 P（`exploring` / `implementing` / `on-hold`）→ 拒绝并回报「当前有进行中的提案 P-XXX（状态），请完成当前需求周期后再升级」，流程终止，无 override。
- **触发**：slim 命中且用户显式确认升级（单问题 opt-in）。
- **新增生成**：`sdd/INITIATIVE.md`（骨架见 command-specs，`next-I: 001` 起）、`sdd/amendments/amend.md`、`sdd/templates/` 增 `proposal.md` + `task.md`（纯复制自 `templates/` 顶层）、`.claude/commands/` 增 `sdd-finalize.md` + `sdd-split.md` + `sdd-archive.md`（frontmatter 照抄 `references/command-specs.md` 命令规格表）、`.opencode/commands/` 同名存根 ×3、`sdd/archive/README.md`。
- **重生成（覆盖 slim 版）**：`sdd/CONSTITUTION.md`（按 `references/constitution-design.md` full 骨架逐字，项目名回填、生效日期保留原值）、`CLAUDE.md`（full 骨架：命令一览 ×7、edition 行改 `edition：full`、移除缺席命令解释）、`sdd/INDEX.md`（**意向小节整节迁出后**按 full 骨架重写）。
- **数据迁移（唯一一次）**：意向行逐条迁入 `INITIATIVE.md` 获发 `I-XXX`（next-I 自 001 递增，原始念头文字保留），回报列迁移对照表（意向行 → I 号）。
- **原样不动**：`sdd/specs/` 全部文件、`sdd/exploring/journal.md`、`sdd/tools/mdlint.sh`。
- **版本标记**：`VERSION` → `X.Y.Z+full`。
- **提交**：前置校验 git 索引干净（`git diff --cached --quiet`）；两批显式列举：第一批治理资产（CONSTITUTION + CLAUDE.md + INDEX + INITIATIVE + amend + templates ×4 + 命令 ×7 + VERSION + archive/README），消息固定 `chore: 升级 SDD 治理体系至完整版（edition: full）`；第二批 OpenCode（存根 ×3），消息固定 `chore: 补齐 OpenCode 适配存根至完整版`；零变更批次跳过。
- **验证**：按 full 清单全量验证（29 文件齐备、opencode debug config 7 命令、mdLint 零 error）。
- **回报**：edition 去向（`0.1.0+slim → 0.2.0+full` 形态）+ 补齐清单 + 意向迁移对照表 + 跳过批次 + commit hash + mdLint 结论 + 验证结论 + 升级耗时。
