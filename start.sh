#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

if [[ ! -f config.yaml ]]; then
  printf '请先运行 bash prepare.sh，再编辑 config.yaml。\n' >&2
  exit 1
fi
if grep -Eq 'REPLACE_WITH_YOUR_SUBSCRIPTION|YOUR_RESIDENTIAL_HOST|YOUR_USERNAME|YOUR_PASSWORD' config.yaml; then
  printf 'config.yaml 仍有占位符，请先填写自己的机场订阅和住宅代理信息。\n' >&2
  exit 1
fi
if [[ ! -x ./mihomo ]]; then
  printf '未找到可执行的 Mihomo，请先运行 bash prepare.sh。\n' >&2
  exit 1
fi
chmod 600 config.yaml
./mihomo -t -d . -f config.yaml
exec ./mihomo -d . -f config.yaml
