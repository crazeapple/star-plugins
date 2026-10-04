# star-plugins

Claude Code 插件 monorepo：一个 marketplace（`star-plugins`），多个插件，每个插件位于 `plugins/<plugin>/`，经 marketplace 清单统一分发。

## 插件一览

| 插件 | 状态 | 说明 |
|---|---|---|
| `sdd` | 可用 | SDD 需求治理体系：在任意目标项目一键生成治理体系（slim / full 双 edition，slim 精简真子集、单向可升；inline / standalone 双治理形态，standalone 治理另立仓、项目仓零痕迹）并适配 OpenCode |
| `src-reading` | 规划中 | 尚未开工 |
| `ctx-alarm` | 规划中 | 尚未开工 |

## 安装

```
/plugin marketplace add <本仓路径或 git 地址>
/plugin install sdd@star-plugins
```

安装后新会话即可调用 `/sdd:sdd-init`。

## sdd 插件

- **skill `sdd-init`**：可移植初始化器，在任意目标项目生成整套 SDD 治理体系（`sdd/` 治理文档与 runtime / mdLint 工具 / 命令 / 项目骨架 `CLAUDE.md` 与 `AGENTS.md`；**slim / full 双 edition**：slim 精简真子集，需求明确、规模可控时选用，单向可升；**inline / standalone 双治理形态**：inline 治理随项目仓，standalone 治理另立 `sdd/` 内层仓、项目仓零痕迹，init 后不可切换）、完成 OpenCode 适配并安装 `.git/hooks/pre-commit` 提交兜底
- **hook（提交兜底，纪律机制化）**：sdd-init 装进目标项目 `.git/hooks/pre-commit`，提交时对 staged 辖区 `.md` 跑 mdLint，有 error 阻止提交（三端通用：Claude Code、OpenCode、人工提交）
- 插件**不含**工作流命令：命令由 sdd-init 生成于目标项目内（`.claude/commands/`），避免与项目内命令重复，且 OpenCode 存根依赖项目内文件

### 设计权威

`docs/DESIGN-SDD.md` 是 SDD 体系的设计总纲（命名体系 / 三层实体 Initiative-Proposal-Task / 两路流程 / 判据测试 / 自治阶梯 / Git 工作流）；sdd 插件规格以它为准演进。

### 使用

在目标项目根调用 `/sdd:sdd-init`，交互回答必填项，完成后待命 `/sdd-intake` 接首个需求。详见 `plugins/sdd/skills/sdd-init/SKILL.md`。

### 生命周期

- **升级**：目标项目内重跑 `/sdd:sdd-init`，检测到既有安装自动转升级模式（就地合并），机械资产静默更新、活文档差异仲裁、运行态（INDEX / INITIATIVE / specs 等）永不触碰；版本基线记录于 `sdd/VERSION`。规格见 `plugins/sdd/skills/sdd-init/references/upgrade.md`。
- **环境重建**：项目在新主机 clone 后本地 `.git/hooks/pre-commit` 必然缺失（客户端 hook 不随 git 目录迁移）。重跑 `/sdd:sdd-init`，运行态齐全即自动转升级模式并补装 hook。
- **卸载**：插件卸载对已初始化项目零影响（零运行时耦合，复制交付即断奶），仅失去后续升级通道；不做项目级拆除功能，停用体系删文件即可，pre-commit hook 自防御（`sdd/tools/mdlint.sh` 缺失即静默放行），git 历史保全一切。裁决见 `DESIGN-SDD.md` §十六。

### 分层读取设计

sdd 生成的治理文档分两层控制上下文成本：

- **`CLAUDE.md`（约 1k tokens）**：每个会话由 Claude Code 自动注入，是不论会话做什么都要付的固定开销，因此内容保持最小，即硬规则摘要、命令一览与路径指路；自成一篇，即使 Agent 没读宪法，单独也能撑起最小心智。
- **`CONSTITUTION` → `INDEX` → `INITIATIVE`（合计约 7-9k tokens）**：只在会话需要开展治理工作时读取一次，此后在该会话内持续可用、不再重复读取；不随新会话自动注入，纯写码会话零成本。

`CLAUDE.md` 指向下层：Agent 顺着指路按当前任务需要继续读取。

## 目录结构

```
star-plugins/
├── .claude-plugin/
│   └── marketplace.json              # marketplace 清单（star-plugins）
├── docs/                             # 插件元文档：一插件一组
│   ├── DESIGN-SDD.md                 # SDD 设计总纲
│   └── PROMPT-SDD.md                 # 单文件版可移植初始化提示词
└── plugins/                          # 插件 monorepo：一插件一目录
    └── sdd/
        ├── .claude-plugin/
        │   └── plugin.json           # 插件清单（name: sdd）
        └── skills/sdd-init/
            ├── SKILL.md              # 初始化主流程（引用懒加载）
            ├── references/           # 逐字规格
            ├── templates/            # 模板（装进目标项目）
            └── scripts/              # 治理工具：mdlint.sh + pre-commit.sh（装进目标项目）
```

## 仓库现状一览

| 层 | 内容 |
|---|---|
| 设计 | `DESIGN-SDD.md`（十六节总纲：命名体系 / Initiative-Proposal-Task 三层 / 两路流程 / 判据测试 / 自治阶梯 / 执行策略 / Git 工作流 / 生命周期） |
| 可移植提示词 | `PROMPT-SDD.md`（单文件版，与 DESIGN-SDD 同源） |
| marketplace | `.claude-plugin/marketplace.json`（`star-plugins`：当前仅收录 `sdd`） |
| 插件 | `plugins/sdd/`：sdd-init（生成规格 references ×5：constitution-design / command-specs / opencode-adapter / upgrade / slim + 模板 ×6 + hook 脚本 ×2）+ pre-commit 提交兜底 |
| 仓库指引 | `CLAUDE.md` / `README.md` |
