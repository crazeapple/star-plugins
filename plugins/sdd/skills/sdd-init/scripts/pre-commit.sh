#!/bin/sh
# pre-commit — R8 提交兜底：staged 的 mdLint 辖区 .md 有 error 即阻止提交（三端通用：Claude Code、OpenCode、人工提交）
# 行为：取 staged 新增/复制/修改/重命名文件，过滤 mdLint 辖区（sdd/ 下、CLAUDE.md、CHANGELOG.md、.claude/commands/、AGENTS.md、.opencode/commands/），
#       命中则整体交 sdd/tools/mdlint.sh 校验；有 error 以退出码 1 + stderr 阻止提交，无 error（含仅 warning）静默放行。
# 前提：git 以仓库根为 cwd 运行本 hook；sdd/tools/mdlint.sh 缺失时静默放行（防御）。
# 局限：含空白字符的路径未覆盖（治理文档文件名一律英文 kebab-case）；warning 不拦截。

[ -f sdd/tools/mdlint.sh ] || exit 0

files=$(git diff --cached --name-only --diff-filter=ACMR -- sdd CLAUDE.md CHANGELOG.md .claude/commands AGENTS.md .opencode/commands | grep '\.md$')
[ -n "$files" ] || exit 0

out=$(sh sdd/tools/mdlint.sh $files 2>&1)
if [ $? -ne 0 ]; then
  printf 'mdLint 发现 error（提交被阻止：修复后重新 git add 再提交）：\n%s\n' "$out" >&2
  exit 1
fi
exit 0
