#!/bin/sh
# pre-commit — 提交门禁：先本地写回，后门禁断言
# 激活：git config core.hooksPath .githooks（见 README 运行说明；未激活本 hook 不生效）
# 结构：路由段（登记工具按文件模式执行）+ 内嵌 mdlint 段（全部 staged .md 书写形态校验）
# 顺序：写回路由（成功后重暂存命中文件）→ 断言路由（非零退出即阻断）→ mdlint（error 阻断）
# 前提：git 以仓库根为 cwd 运行本 hook；局限：含空白字符的路径未覆盖，warning 不拦截

set -u

# ---------- 路由段（生成区：登记变更时增补） ----------
# 每行一条路由，格式：glob|处置|命令（命令追加命中文件，勿含空格路径）
# 处置取值：write（写回，成功后重暂存命中文件）/ assert（断言，非零退出即阻断提交）
# BEGIN ROUTES
# END ROUTES

files=$(git diff --cached --name-only --diff-filter=ACMR)
[ -z "$files" ] && exit 0

routes=$(sed -n '/^# BEGIN ROUTES$/,/^# END ROUTES$/p' "$0" | grep -v '^#')

# 路由执行：mode = write | assert
run_routes() {
  mode=$1
  while IFS= read -r line; do
    case "$line" in ''|'#'*) continue ;; esac
    glob=${line%%|*}; rest=${line#*|}; disp=${rest%%|*}; cmd=${rest#*|}
    [ "$disp" = "$mode" ] || continue
    hits=""
    for f in $files; do
      case "$f" in $glob) hits="$hits $f" ;; esac
    done
    [ -z "$hits" ] && continue
    # shellcheck disable=SC2086
    if ! $cmd $hits; then
      printf 'pre-commit: 门禁阻断：%s（%s）\n' "$cmd" "$mode" >&2
      exit 1
    fi
    if [ "$mode" = write ]; then
      # shellcheck disable=SC2086
      git add $hits
    fi
  done <<EOF
$routes
EOF
}

# ---------- 内嵌 mdlint 段 ----------
lint_file() {
  perl - "$1" <<'PERL'
use strict;
use warnings;
use open qw(:std :encoding(UTF-8));

my $file = shift;
open(my $fh, '<:encoding(UTF-8)', $file) or die "mdlint: cannot open $file: $!\n";
my @lines = <$fh>;
close $fh;

my $err = 0;
my $warn = 0;
my $in_fence = 0;
my (@body, @plain);          # body：非围栏行（保留原样）；plain：剥离行内代码后的行
my @src_line;                # body 行对应的原文件行号

for my $i (0 .. $#lines) {
  my $l = $lines[$i];
  if ($l =~ /^\s*(```+|~~~+)/) { $in_fence = !$in_fence; next; }
  next if $in_fence;
  push @body, $l;
  push @src_line, $i + 1;
}

for my $i (0 .. $#body) {
  my $l = $body[$i];
  my $n = $src_line[$i];
  my $s = $l;

  # error：行内反引号不配对
  my $ticks = () = $l =~ /`/g;
  if ($ticks % 2 == 1) {
    printf "error: %s:%d: 行内反引号不配对\n", $file, $n;
    $err++;
    next;
  }
  # 剥离行内代码
  $s =~ s/`[^`]*`//g;

  # error：** 行内不配对（剥离行内代码后）
  my $stars = () = $s =~ /\*\*/g;
  if ($stars % 2 == 1) {
    printf "error: %s:%d: ** 不配对\n", $file, $n;
    $err++;
  }
  # warning：中英文粘连（剥离行内代码后；× 依规范须与中文隔空格，纳入检查）
  if ($s =~ /[\x{4e00}-\x{9fff}][A-Za-z0-9×]/ || $s =~ /[A-Za-z0-9×][\x{4e00}-\x{9fff}]/) {
    printf "warning: %s:%d: 中英文粘连\n", $file, $n;
    $warn++;
  }
  # warning：行内代码内出现 ID 形态（裸写为合规态）
  for my $span ($l =~ /`([^`]*)`/g) {
    if ($span =~ /[IPTA]-[0-9]{3}/) {
      printf "warning: %s:%d: 行内代码内出现 ID 形态\n", $file, $n;
      $warn++;
      last;
    }
  }
  # warning：无序列表标记非 -
  if ($l =~ /^\s*[*+]\s+/) {
    printf "warning: %s:%d: 无序列表标记非 -\n", $file, $n;
    $warn++;
  }

  push @plain, $s;
}

# warning：表格行列数与表头不一致（逐段连续 | 行；分隔行跳过；行内代码先剥离）
my $i = 0;
while ($i <= $#body) {
  my $l = $body[$i];
  if ($l !~ /^\s*\|/) { $i++; next; }
  my $s = $l;
  $s =~ s/`[^`]*`//g;
  if ($s =~ /^\s*\|[\s:\-]*\|\s*$/) { $i++; next; }   # 单独分隔行不成表
  my $head = ($s =~ tr/|//) - 1;
  my $j = $i + 1;
  my $rownum = 1;
  while ($j <= $#body && $body[$j] =~ /^\s*\|/) {
    my $t = $body[$j];
    $t =~ s/`[^`]*`//g;
    if ($t =~ /^\s*\|[\s:\-]*\|\s*$/) { $j++; $rownum++; next; }
    my $c = ($t =~ tr/|//) - 1;
    if ($c != $head) {
      printf "warning: %s:%d: 表格行列数与表头不一致（表头 %d 列，第 %d 行 %d 列）\n", $file, $src_line[$j], $head, $rownum + 1, $c;
      $warn++;
    }
    $j++;
    $rownum++;
  }
  $i = $j;
}

# error：全角圆括号/直角引号文件级配对（对剥离行内代码后的全文）
my $full = join('', @plain);
my $open_p = () = $full =~ /（/g;
my $close_p = () = $full =~ /）/g;
if ($open_p != $close_p) {
  printf "error: %s: 全角圆括号不配对（（ %d 个，） %d 个）\n", $file, $open_p, $close_p;
  $err++;
}
my $open_q = () = $full =~ /「/g;
my $close_q = () = $full =~ /」/g;
if ($open_q != $close_q) {
  printf "error: %s: 直角引号不配对（「 %d 个，」 %d 个）\n", $file, $open_q, $close_q;
  $err++;
}

printf "mdlint: %s: %d error, %d warning\n", $file, $err, $warn;
exit($err ? 1 : 0);
PERL
}

# ---------- 执行：写回 → 断言 → mdlint ----------
run_routes write
run_routes assert

md_err=0
for f in $files; do
  case "$f" in
    *.md) lint_file "$f" || md_err=$((md_err + 1)) ;;
  esac
done
if [ "$md_err" -gt 0 ]; then
  printf 'pre-commit: staged .md 存在 error，阻止提交\n' >&2
  exit 1
fi

exit 0
