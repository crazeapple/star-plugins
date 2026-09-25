#!/bin/sh
# pre-commit（内层治理仓变体）——standalone 形态治理文档提交兜底
# 与外层 .git/hooks/pre-commit 的差异：内层仓根即治理根，辖区 = 全部 staged .md（路径无 sdd/ 前缀）
# 行为：取 staged 新增/复制/修改/重命名文件中的 .md，整体交 tools/mdlint.sh 校验；
#       有 error 以退出码 1 + stderr 阻止提交，无 error（含仅 warning）静默放行。
# 前提：git 以内层仓根（sdd/）为 cwd 运行本 hook；tools/mdlint.sh 缺失时静默放行（防御）。
# 局限：含空白字符的路径未覆盖（治理文档文件名一律英文 kebab-case）；warning 不拦截。

[ -f tools/mdlint.sh ] || exit 0

files=$(git diff --cached --name-only --diff-filter=ACMR | grep '\.md$')
[ -n "$files" ] || exit 0

out=$(sh tools/mdlint.sh $files 2>&1)
if [ $? -ne 0 ]; then
  printf 'mdLint 发现 error（提交被阻止：修复后重新 git add 再提交）：\n%s\n' "$out" >&2
  exit 1
fi
exit 0
