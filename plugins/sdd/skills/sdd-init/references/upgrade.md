# 升级模式：既有 SDD 安装的就地合并（生成与验证的唯一规格源）

> 触发判定、校准分类、验证与回报以本文件为唯一规格源；设计决策见仓库 `docs/` 目录的 `DESIGN-SDD.md` §十六。升级复用初始化的四步骨架与全量验证，不新增命令。

## 一、触发判定

前置检查的冲突检测命中项构成**全套签名文件**时，经用户确认转升级模式；任一缺失则照旧停止并报告冲突清单：**部分存在不触发升级**，禁止自行补齐缺失项后覆盖。

签名集（以下存在性检查全部命中才转升级）：

- `sdd/CONSTITUTION.md`、`sdd/INDEX.md`、`sdd/INITIATIVE.md`、`sdd/amendments/amend.md`
- `sdd/templates/` 下 proposal / spec / design / task ×4 全在
- `sdd/tools/mdlint.sh`、`sdd/archive/README.md`
- `CLAUDE.md`、`.claude/commands/` 下 7 命令全在
- `AGENTS.md`、`.opencode/opencode.json`、`.opencode/commands/` 下 7 存根全在

`.gitignore` 与 `.git/hooks/pre-commit` 不入签名集（补装语义：缺失即补，存在即覆盖 / 补行）。典型场景为环境重建：项目于新主机 clone 后 `.git/hooks/pre-commit` 必然缺失，全套签名文件在库即命中本模式，重装即补。命中后向用户明示「检测到既有安装（版本与 edition 见 `sdd/VERSION`），转入升级模式」并等待确认；确认后校验 git 索引干净（`git diff --cached --quiet`），有预置暂存则停止，请用户先处理（防混入升级提交）。

**形态判定**：`sdd/` 为独立 git 仓（存在 `sdd/.git`）即 standalone 形态，否则 inline；既有低版本安装（无 `sdd/runtime/`）一律视为 inline，升级时先执行 §六末「2.0.0 一次性迁移」再校准。standalone 安装预检双仓索引干净（外层与 `git -C sdd diff --cached --quiet` 均过）。升级永远维持当前形态，不提供形态切换。

**edition 路由**：命中签名集后读 `sdd/VERSION` 判 edition（取 `+` 后段；裸版本为 edition 后缀引入前的旧版，视为 full），**full 命中**按本文件以下各节校准；**slim 命中**单问题「升级到 full 版？」，回车默认 slim 原地校准（走 `references/slim.md` §八），显式确认 → 按该文件 §九升 full 版（前置闸门：INDEX 存在非终态 P 则拒绝切换）。slim 签名集 = `sdd/CONSTITUTION.md`、`sdd/INDEX.md`、`sdd/templates/` 下 spec / design ×2、`sdd/tools/mdlint.sh`、`CLAUDE.md`、`.claude/commands/` 下 4 命令、`AGENTS.md`、`.opencode/opencode.json`、`.opencode/commands/` 下 4 存根。

## 二、校准分类（三档）

| 档 | 文件 | 处置 |
|---|---|---|
| 静默覆盖 | `sdd/tools/mdlint.sh`、`.git/hooks/pre-commit`（重装并加可执行位；standalone 另装内层 `sdd/.git/hooks/pre-commit` 变体）、`sdd/templates/` ×4、`.claude/commands/` ×7、`.opencode/opencode.json`、`.opencode/commands/` ×7 | 按规格纯复制覆盖 |
| 保护性写入 | `.gitignore`（inline）、`AGENTS.md`、`sdd/CONSTITUTION.md`、`sdd/runtime/claude.md` | 规格重生成 + 项目内容回读回填（见下） |
| 活文档仲裁 | `sdd/runtime/claude.md`（CLAUDE.md 公开骨架一并按规格重写） | 骨架节重写 + 项目内容保留（§六） |
| 禁触 | `sdd/INDEX.md`、`sdd/INITIATIVE.md`、`sdd/amendments/amend.md` 内容；`sdd/specs/`、`sdd/exploring/`、`sdd/journal.md`、`sdd/archive/` 全部 | 一律不改（骨架仅按 §八锚点只读比对） |

保护性写入细则：

- `.gitignore`（inline 形态）：三行逐行补缺，即 `# 本地文件不入库`、`*.local.*`、`.worktree/`；已有行不动，项目自有行禁删禁改，文件不存在才新建；**严禁整文件重写**。standalone 形态不写 `.gitignore`，改维护 `.git/info/exclude` 六行排除清单（逐行补缺，同款纪律）。
- `AGENTS.md`：按 `references/opencode-adapter.md` 逐字重生成，项目名回填（§三回读值）。
- `sdd/CONSTITUTION.md`：按 `references/constitution-design.md` 逐字重生成，项目名回填（§三回读值）；末尾生效日期保留原文件原值（识别原文件末尾 `YYYY-MM-DD` 日期行；回读失败以当日 `date +%F` 重置并在回报注明）。

## 三、必填项回读（升级模式不询问）

项目名 ← `CLAUDE.md` 首行标题（备选 `AGENTS.md` 标题）；项目定位一句话 ← `CLAUDE.md` 首段定位句；提交前校验命令 ← `sdd/runtime/claude.md`「路径、ID 与工程约定」节（2.0.0 前旧结构 ← 旧 `CLAUDE.md` 同名节）。三项均回读不到时询问用户（升级模式唯一询问点），拒答按默认值生成并在回报注明。

## 四、执行顺序与幂等

1. 起始时间戳（`date +%s`）→ 触发判定（§一）→ 必填项回读（§三）
2. 两路并行校准（§七）→ 主会话最后重写 `sdd/runtime/claude.md` 与 `CLAUDE.md`（同初始化的串行屏障）→ 写 `sdd/VERSION`（内容 = `${CLAUDE_SKILL_DIR}/../../.claude-plugin/plugin.json` 的 `version` 原样）
3. 全量验证（复用 SKILL.md「四、验证与回报」全量项：mdLint 零 error + 交叉一致 + check-ignore + opencode debug config）→ 提交（§五）→ 回报（§五）

**幂等**：校准按「现行规格 vs 磁盘现状」状态化执行，不依赖版本值分支；升级可安全重跑，中断恢复 = 直接重跑（中断不会造成签名集缺损，重跑仍命中升级模式）。

## 五、提交与回报

- 提交按实际变更文件显式列举、禁用 `git add -A` 与 `git add .`，分两批（同初始化分主题）：第一批 = `CLAUDE.md` + 命令 ×7 + `sdd/CONSTITUTION.md` + `sdd/VERSION`，消息固定 `chore: 升级 SDD 治理体系（机械资产校准 + 活文档仲裁）`；第二批 = `AGENTS.md` + `.gitignore` + `.opencode/opencode.json` + `.opencode/commands/` ×7，消息固定 `chore: 升级 OpenCode 适配资产`。某批零变更 → 跳过并在回报注明（commit hash 为 0 / 1 / 2 个）。standalone 形态：治理资产变更 `git -C sdd` 提交（消息同第一批固定文案）；项目仓仅公开骨架（CLAUDE.md / AGENTS.md）有变更时一笔中性 message 固定 `docs: 更新项目协作入口`，无变更则项目仓零提交。
- 回报项：治理形态 + 模式与版本去向（含 edition 段，如 `0.1.0+full → 0.2.0+full`；「旧版安装 → Y」）+ 覆盖清单 + 仲裁结果（保留的项目字段与自有增补清单、被覆盖改动清单）+ 骨架差异报告（§八，无差异则注明）+ 迁移清单（2.0.0 一次性迁移）+ 跳过批次 + commit hash（standalone 为两仓各自）+ mdLint 结论 + 各项验证结论 + 升级耗时（总时长，人类可读格式）+ hook 重装结论（含 standalone 内层 hook）。

## 六、CLAUDE.md 重写与回读规则

- 按节标题锚点识别骨架（2.0.0 起骨架在 `sdd/runtime/claude.md`：需求层级 / 会话必读 / 命令一览 / 硬规则 / 路径、ID 与工程约定 + 溯源行；CLAUDE.md 为公开项目骨架），以 `references/command-specs.md` 对应骨架规格重写。
- 命令一览表与硬规则属单源复制辖区：项目改写过也**以规格为准重写**，被覆盖改动逐项列入回报（用户可经 git 历史回退）。
- 项目填写三字段（项目名 / 定位一句话 / 提交前校验命令）回读保留（§三）；识别不到骨架锚点的小节视为项目自有内容，**原样保留**并在回报列出。
- **2.0.0 一次性迁移（inline 旧安装，仅此一次）**：识别旧结构（CLAUDE.md 含骨架六节、无 `sdd/runtime/`）→ 回读三字段与项目自有增补节 → 生成 `sdd/runtime/claude.md`（六节的 sdd 部分与溯源行迁入，措辞按现行规格）→ 重写 CLAUDE.md 为公开项目骨架（三字段回填、自有增补节原样保留、inline 加 `@sdd/runtime/claude.md` 行）→ `AGENTS.md` 改项目骨架、`opencode.json` 增 `instructions`、新增 `sdd/runtime/opencode.md`（均按 opencode-adapter 规格）→ 回报列迁移清单（何文件何节迁往何处）。迁移后走常规校准；standalone 安装天然为新结构，无迁移。

## 七、执行策略（两路并行）

- 组 U① 治理组：`CONSTITUTION.md` 重生成 + `INDEX.md` / `INITIATIVE.md` / `amendments/amend.md` 骨架锚点只读比对（§八），自读本文件全文 + `references/constitution-design.md` 全文 + `references/command-specs.md` 生成骨架节。
- 组 U② 机械资产组：命令 ×7、模板 ×4、`mdlint.sh`、hook（含 standalone 内层变体）、OpenCode 适配 ×11 覆盖，自读本文件全文 + `references/opencode-adapter.md` 全文。
- 主会话自读本文件全文（runtime/claude.md 仲裁、验证与提交操盘，升级模式不适用「主会话无需预读」豁免）；不支持 subagents 时按 U① → U② → 主会话串行，步骤不变。

## 八、骨架差异比对与报告

只比锚点不比全文。INDEX 比 `next-P` / `next-T` 计数器标签在位 + 提案总览表表头列集合与现行规格一致；INITIATIVE 比 `next-I` 标签在位 + 条目格式引言行在位；`amendments/amend.md` 比 `next-A` 标签在位 + 条目格式指引行在位。计数器值、数据行、条目内容一律不参与比对（防活跃项目误报）。

报告格式固定：每文件一段 = 文件名 + 差异锚点清单 + 「人工迁移建议：对照 command-specs 对应骨架节」+ 明示「未自动修改」。

## 九、边界处置

- **部分安装**：照旧冲突停止并列缺失项（§一），禁止补齐后覆盖。
- **`sdd/VERSION` 缺失或损坏**（内容不匹配 `^[0-9]+\.[0-9]+\.[0-9]+\+(slim|full)$`；裸版本为 edition 后缀引入前的旧版，视为 full）：照常升级（校准不依赖版本值），回报注明「旧版安装」或「版本标记异常，疑似损坏 / 篡改」。
- **opencode 未安装**：验证对应项跳过并在回报注明（同初始化条款，禁止自动安装）。
- **worktree 在途**：升级只写主干路径，与 worktree 内代码零交集；回报列 `ls .worktree/` 在途提案作提示；hook 重装落 `.git/hooks/`（共享 git dir），对全部 worktree 即时生效属预期。
- **并发改写**：不对 CLAUDE.md 加锁；提交前全量验证 + 幂等重跑兜底。
