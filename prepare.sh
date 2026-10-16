#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

for command_name in gzip sha256sum awk; do
  command -v "$command_name" >/dev/null 2>&1 || {
    printf '缺少命令：%s，请先安装后再运行。\n' "$command_name" >&2
    exit 1
  }
done

case "$(uname -m)" in
  x86_64|amd64) archive='core/mihomo-linux-amd64-v1-v1.19.31.gz' ;;
  aarch64|arm64) archive='core/mihomo-linux-arm64-v1.19.31.gz' ;;
  *) printf '暂未内置此架构的内核，请从 Mihomo 官方下载对应版本。\n' >&2; exit 1 ;;
esac

expected_hash=$(awk -v file="$archive" '$2 == file { print $1 }' SHA256SUMS)
if [[ -z "$expected_hash" || ! -f "$archive" ]]; then
  printf '内核或校验文件缺失，请下载完整仓库。\n' >&2
  exit 1
fi
printf '%s  %s\n' "$expected_hash" "$archive" | sha256sum -c -

temporary_binary=$(mktemp ./mihomo.unpack.XXXXXX)
trap 'rm -f -- "$temporary_binary"' EXIT
gzip -dc -- "$archive" > "$temporary_binary"
chmod 755 "$temporary_binary"
mv -f -- "$temporary_binary" ./mihomo
trap - EXIT

if [[ ! -e config.yaml ]]; then
  (umask 077; cp -- config.example.yaml config.yaml)
  chmod 600 config.yaml
  printf '已生成 config.yaml，请填写标有【必填】的 5 项。\n'
else
  printf '保留已有 config.yaml，未覆盖其中的设置。\n'
fi
printf '准备完成。编辑好配置后运行：bash start.sh\n'
