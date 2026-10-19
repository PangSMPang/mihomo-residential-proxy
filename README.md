# Mihomo Residential Proxy

让 Linux 服务器上的程序通过“机场前置 + 住宅代理”访问网络。提供带注释的配置模板、中文教程，以及 Linux amd64 / arm64 内核，填入自己的信息后即可启动。

```text
服务器程序 → 本机 Mihomo → 机场节点 → 住宅代理 → 目标网站
```

## 快速开始

需要 Linux 服务器，以及 Bash、Git、gzip、sha256sum 等常用工具。默认提供本机代理端口，不要求 root 权限。

```bash
git clone https://github.com/PangSMPang/mihomo-residential-proxy.git
cd mihomo-residential-proxy
bash prepare.sh
```

也可以通过 GitHub 的 **Code → Download ZIP** 下载完整仓库，解压后进入目录，再运行 `bash prepare.sh`。

准备脚本会自动识别 amd64 / arm64、校验并解压随附的内核，再从公开模板生成 `config.yaml`。如果已有配置，脚本会保留它。

编辑生成的 `config.yaml`，只需填写标有【必填】的 5 项：

| 字段 | 填什么 |
|---|---|
| 机场订阅 `url` | 自己的 Mihomo/Clash 格式节点订阅链接 |
| 住宅节点 `server` | 住宅代理 IP 或域名 |
| 住宅节点 `port` | 住宅代理端口，填写数字 |
| 住宅节点 `username` | 住宅代理用户名 |
| 住宅节点 `password` | 住宅代理密码 |

默认使用 SOCKS5 住宅代理。若商家提供 HTTP，把住宅节点的 `type: socks5` 改成 `type: http`。`server` 只填 IP 或域名，不要粘贴整条代理链接；保留 `dialer-proxy: AIRPORT`。

默认从机场订阅中按顺序使用可用节点。只使用新加坡时，可以取消模板里 `filter` 那一行的注释，并确认节点名称能被匹配。

填写完成后前台启动：

```bash
bash start.sh
```

首次启动需要下载机场订阅；服务器须能访问订阅地址和前置节点。模板已为订阅下载设置 `User-Agent: clash-verge/v2.4.7`，与该版本 Clash Verge 的默认请求标识一致。部分机场会按请求标识返回不同内容；如果客户端能正常更新，内核却只拿到“当前设备未授权”等提示节点，先核对模板的 `proxy-providers.AIRPORT_SUB.header.User-Agent`，不要仅凭提示认定电脑未授权。使用其他订阅时，可按商家要求调整或删除该请求头；若核对后仍有限制，再确认商家的设备绑定要求。

## 验证最终出口

保持程序运行，在另一个终端执行：

```bash
curl --noproxy "" --connect-timeout 10 --max-time 30 \
  --proxy http://127.0.0.1:18080 https://api.ipify.org
```

返回值应与商家提供的住宅**出口 IP**一致。有些商家的代理接入地址与出口 IP 不同，以商家后台为准。

让服务器程序使用以下地址即可：

```text
HTTP 代理：http://127.0.0.1:18080
SOCKS5 代理：socks5h://127.0.0.1:18080
```

`socks5h` 是 curl 等部分工具支持的写法，用于让代理解析目标域名。其他程序按其 SOCKS5 设置填写。

支持代理环境变量的程序，可在启动它的同一个终端设置：

```bash
export http_proxy=http://127.0.0.1:18080
export https_proxy=http://127.0.0.1:18080
```

验证成功后，可按 `Ctrl+C` 停止前台进程，改成后台运行：

```bash
nohup bash start.sh >mihomo.log 2>&1 &
```

查看日志：`tail -n 50 mihomo.log`。后台运行不包含开机自启。

## 文件说明

| 文件 | 用途 |
|---|---|
| [config.example.yaml](./config.example.yaml) | 公开配置模板，仅包含占位符 |
| [prepare.sh](./prepare.sh) | 自动校验、解压内核并生成本机配置 |
| [start.sh](./start.sh) | 检查占位符、校验配置并启动 |
| [服务器教程.md](./服务器教程.md) | 可放进文章的精简服务器章节 |
| [使用说明.md](./使用说明.md) | 字段示例、调试方法及常见问题 |
| `core/` | Linux amd64 / arm64 官方内核压缩包及来源清单 |
| `third-party/` | Mihomo 许可证与对应版本源码归档 |
| [SHA256SUMS](./SHA256SUMS) | 内核和源码归档的校验值 |
| [THIRD_PARTY.md](./THIRD_PARTY.md) | 内核来源、版本及许可证说明 |

## 适用范围

只为本机程序提供代理，不会自动接管服务器全部网络流量，也不需要开放公网端口。Docker 等独立网络环境需要另行配置。该仓库没有配置供手机、电脑远程导入的加密入站。

所有交给代理端口的目标请求统一走住宅出口；机场前置组没有节点时停止连接。机场订阅下载和健康检查用于获取及测试前置节点，不代表住宅代理链已通过验证。

真实配置 `config.yaml`、订阅缓存和日志已加入 `.gitignore`。公开分享 [模板原始文件](https://raw.githubusercontent.com/PangSMPang/mihomo-residential-proxy/main/config.example.yaml) 即可；每位使用者自行填写订阅和账号密码。

住宅出口 IP 的连通性、住宅分类及特定网站的可用性需要分别判断，本项目不保证特定服务解锁。

## 上游

内核为 [Mihomo v1.19.31](https://github.com/MetaCubeX/mihomo/releases/tag/v1.19.31) 官方 Linux 版本，许可证和对应源码随附。详见 [第三方说明](./THIRD_PARTY.md)。
