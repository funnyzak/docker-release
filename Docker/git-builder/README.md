# Git Builder

`funnyzak/git-builder` 是通用的 Git Webhook 构建与运行镜像，提供 Node.js、Java 和常用构建工具。通过配置指定代码仓库、构建步骤、产物路径、发布脚本和服务启动命令，并使用 curl 向外部 Apprise API 发送阶段通知。

同一镜像可以运行多个独立实例，每个实例对应一个可信仓库和一套流水线，使用各自的配置与数据卷。实例数量和部署位置由使用方决定，各实例独立接收 Webhook、执行任务。

按需选择构建后行为：仅归档产物、通过 `after_build` 执行发布脚本，或通过 `runtime` 在同容器运行并更新一个常驻服务。

## 环境与架构

| 工具 | 镜像版本 |
| --- | --- |
| Node.js / npm | Node 24.14.0 / 随该 Node 镜像提供的 npm |
| JDK | Eclipse Temurin 17.0.18+8 |
| Maven | 3.9.9 |
| pnpm | 10.18.2 |
| Webhook | adnanh/webhook 2.8.3 |
| 字体 | fontconfig、DejaVu、Noto CJK，支持 Java 无图形界面的图片绘制及中文文字 |
| 基础系统 | Debian Bookworm slim，包含 Git、SSH、curl、rsync、tar、zip |

Dockerfile 面向 `linux/amd64`（x64）和 `linux/arm64`（ARM64）。发布流程默认生成双架构清单，不支持 32 位 ARM。构建发生在容器当前架构；带原生依赖的 Node/Next.js 包应部署到相同架构与兼容系统。

镜像不包含 Docker daemon、Apprise 服务或原生 Node 模块编译工具。业务包在构建后生成，可通过下文 runtime 配置在同容器运行。需要 Python/make/g++ 的项目应派生构建镜像安装相应依赖。Java 其他版本也使用独立派生镜像，不在启动时升级工具链。

## 快速开始

在本目录操作：

```sh
cp .env.example .env
cp examples/npm.json pipeline.json
openssl rand -hex 32
```

编辑 `.env`，填写 `WEBHOOK_TOKEN`、`GIT_REPO_URL`、`GIT_REPO_NAME`。编辑 `pipeline.json`，设置允许的 ref 和项目命令，然后运行：

```sh
docker compose up -d --build
docker compose ps
docker compose logs --tail=100 git-builder
```

默认仅在宿主机 `127.0.0.1:9000` 监听。通过服务器已有反向代理提供 HTTPS，代理到 `http://127.0.0.1:9000`。代理须限制请求体为 1 MiB，Query Token 模式下访问日志使用 `$uri`，不要记录 `$request`、`$request_uri` 或 `$args`。可以为 Webhook 路径单独配置不带查询参数的日志格式。

运行多个实例时，为每个实例分别配置仓库、Token、数据卷和端口。在同一宿主机使用不同 Compose 项目名区分实例，并为每个实例设置未占用的宿主机端口，例如：

```sh
HOST_PORT=9001 docker compose -p builder-example up -d --build
```

默认 Compose 使用 `funnyzak/git-builder:1.0.0`。使用源码构建时运行 `docker compose up -d --build`；使用镜像仓库中已发布的版本时，设置 `GIT_BUILDER_IMAGE`，再运行 `docker compose pull && docker compose up -d --no-build`。

## Webhook 与认证

入口为 `POST /hooks/build`，请求体使用 JSON。认证始终开启，`WEBHOOK_TOKEN` 至少 32 个字符；为空或认证配置无效时拒绝启动。

| WEBHOOK_AUTH_MODE | 发送方式 |
| --- | --- |
| `query`（默认） | `/hooks/build?token=<TOKEN>` |
| `header` | `Authorization: Bearer <TOKEN>` |
| `github` | GitHub Webhook Secret 填写 Token；校验原始请求体的 `X-Hub-Signature-256` |

模式互斥，不能用 Query Token 绕过签名。缺失或错误凭据返回 `401`，不创建任务、不发送通知。签名模式要求 `provider: "github"`。网关不启用 verbose/debug，不记录认证配置。

容器入口自身限制请求体 1 MiB、请求头 8 KiB、读取时间 10 秒和最多 64 个连接，超大请求返回 413。内部 Webhook 只监听 Unix socket，接收原始请求字节验证签名。反向代理的限制是额外约束。

### 通用请求

`provider: "generic"` 使用以下结构：

```json
{
  "event": "push",
  "repository": "your-org/your-repo",
  "ref": "refs/heads/main",
  "sha": "完整的40位Git提交SHA",
  "delivery_id": "每次新事件唯一的ID"
}
```

`repository` 必须等于 `GIT_REPO_NAME`，不能由请求指定克隆地址。示例调用（变量由当前 shell 提供）：

```sh
curl --fail-with-body \
  -H 'Content-Type: application/json' \
  --data-binary @payload.json \
  "${BUILDER_URL}/hooks/build?token=${WEBHOOK_TOKEN}"
```

Header 模式把 Token 放入 `Authorization` 请求头，URL 去掉查询参数。

### GitHub 请求

设置 `provider: "github"`，GitHub 仓库 Webhook 选择 `application/json` 和 Push 事件。仓库使用 `repository.full_name`、提交使用 `after`、去重使用 `X-GitHub-Delivery`。初始 `ping` 只响应，不构建。

Query 模式可直接将 Token 放在 GitHub Payload URL 中，也可使用 `github` 签名模式。GitLab/Gitea 等其他平台的请求需要由发送方转换成 generic 格式。

### 响应及去重

| HTTP 状态 | 意义 |
| --- | --- |
| `202` + `status: queued` | 已持久化，等待执行；响应带任务 `id` |
| `202` + `duplicate: true` | 相同 delivery 已存在，返回已有状态，不重复执行 |
| `202` + `status: ignored` | ping、其他事件、非允许仓库/ref 或删除分支，未创建任务 |
| `401` | 认证失败 |
| `500` | 认证后请求无效、delivery 冲突、队列满、Worker 不可用或持久化失败 |

入口复用 `adnanh/webhook` 的同步命令响应：入队命令出错统一返回 `500`，不透传内部错误码；响应不包含请求内容或凭据。检查服务日志和配置后重试。Git 平台是否自动重投取决于其机制，需要时从平台手动重投。

同一事件重投必须沿用 delivery ID。失败任务不会因重复投递自动重跑；generic 重跑使用新的 `delivery_id`，GitHub 可按 generic 配置另起实例手动构建，或通过新的 Push 触发。去重窗口与任务保留记录一致，删除记录后的旧事件可能再次执行。

## 流水线配置

流水线使用 JSON 配置。以下示例展示不同工具的用法，目录、命令和产物名称均可按项目修改：

- [npm.json](examples/npm.json)：npm ci、构建及 dist 归档。
- [fullstack.json](examples/fullstack.json)：Maven 后端和 pnpm 前端构建。
- [java-runtime.json](examples/java-runtime.json)：使用 Maven 构建 Spring Boot 服务，并在同容器运行新 JAR。

| 字段 | 说明 |
| --- | --- |
| `project` | 项目标识，字母、数字、下划线或横线 |
| `provider` | `generic` 或 `github` |
| `refs` | 允许的完整 ref 数组，如 `refs/heads/main`，不使用通配符 |
| `steps` | 按顺序执行的构建步骤，不能为空 |
| `steps[].name` | 日志和通知使用的步骤名称 |
| `steps[].cwd` | 相对检出目录，默认 `.` |
| `steps[].run` | 受信任的 POSIX shell 命令，由 `/bin/sh -eu -c` 执行 |
| `steps[].timeout_seconds` | 步骤超时，默认继承总超时 |
| `artifacts` | 必须存在的产物路径，归档为独立 tar.gz，不支持 glob |
| `artifacts[].name` / `path` | 包名及相对检出目录的文件/目录路径 |
| `after_build` | 归档成功后的步骤，字段与 steps 相同，默认空数组 |
| `runtime` | 可选，同容器常驻服务，见下节 |
| `timeout_seconds` | 整个任务上限，包含检出、构建、归档和后续步骤，默认 1800 秒 |
| `queue_limit` | 最多等待任务数，不含当前运行任务，默认 20 |
| `keep_runs` | 保留最近结束任务数，默认 20；额外保护运行版本及 latest-success |
| `keep_days` | 已结束任务保留天数，默认 0（关闭）；与次数限制同时生效，任一超限即可清理 |
| `cache_max_mb` | Maven/npm/pnpm 缓存总量阈值，单位 MiB，默认 0（关闭）；超限后重置下载缓存 |
| `max_log_bytes` | 每个任务命令日志上限，默认 10 MiB；超过后继续构建但省略日志 |
| `notifications` | 按事件覆盖通知开关、标题、正文、Apprise tag |

步骤失败即停止。`sh -e` 不会检测管道前段的失败，必要命令请拆成独立步骤；需要 Bash 语义时显式调用 `bash /config/build.sh`。所有命令都必须以前台方式结束，不用 `nohup ... &` 启动长期进程。

配置、凭据或环境变量修改后重启容器。等待任务只持久化提交身份，重启后使用当前挂载配置执行；修改步骤前应先排空队列。数据卷绑定 project 和 repository，更换仓库时必须使用新卷。

### 适配项目目录

`examples/fullstack.json` 假设代码位于 `backend/` 和 `frontend/`，后端输出 `backend/target/app.jar`，前端输出 `frontend/dist/`。使用前修改工作目录、命令和产物路径，使其匹配实际项目；示例中的 `app.jar` 需要 Maven 配置对应的 finalName，或改为真实文件名。

只构建某个工程时删除其他工程的 steps 和 artifacts；一个仓库也可以增加多个前端或后端步骤。Maven 示例默认执行 package 生命周期中的测试，需要跳过时显式添加 `-DskipTests`。Next.js 项目使用 standalone 时，应由项目构建脚本组装完整发布目录，再将该目录声明为产物。

构建用 `.env.production.local`、npmrc、Maven settings 等通过只读挂载配置，再由安装前的步骤复制到临时检出目录；不要把私密配置写入 pipeline.json 或产物。浏览器可见的 Vite/Next.js 公共变量不是保密渠道。环境地址、凭据和部署参数不写入镜像。

## 构建后执行命令或重启服务

`after_build` 在所有产物归档成功后执行。例如挂载一个受信任脚本：

```json
"after_build": [
  {
    "name": "deploy-and-restart",
    "cwd": ".",
    "run": "sh /config/after-build.sh",
    "timeout_seconds": 120
  }
]
```

在 Compose 中增加脚本挂载、部署环境变量及 SSH 凭据。可参考 [after-build.sh](examples/after-build.sh)：它只通过 SSH 重启已存在的远程 systemd 服务，**不上传或安装构建包**；使用前先补上符合实际部署目录的上传、安装操作。需要无交互 sudo 时，在目标服务器限定账号可执行的具体服务命令。

步骤可读取：`BUILD_ID`、`BUILD_SHA`、`BUILD_REF`、`BUILD_PROJECT`、`BUILD_WORKSPACE`、`BUILD_ARTIFACT_DIR`。通过这些环境变量定位当前任务，勿在部署脚本中读取可能仍指向上次任务的 `latest-success`。

容器内直接运行命令只影响容器。重启远程/宿主机服务使用显式配置的 SSH 或部署 API；默认不挂 Docker socket、不授予 privileged。Webhook 请求不能提交脚本或命令，只有受信任配置能定义它们。

后续步骤失败时，任务整体为 `failed`，`build_status` 仍为 `succeeded`，已经归档的包保留。只有构建、后续步骤和可选 runtime 启动全部成功才更新 `latest-success`。自定义部署脚本须自行定义回滚行为；重新执行可能重复外部操作。

## 同容器运行服务并自动更新

设置 `runtime` 后，同一个容器同时提供 Webhook 构建器和一个常驻业务服务：

1. 首次收到 Hook 后构建，健康检查通过才报告发布成功。
2. 后续构建期间旧业务进程继续服务，构建失败不会停止它。
3. 新包归档、after_build 全部成功后，将选定包解压到独立运行目录。
4. 停止旧进程，启动新版本，通过健康检查后持久化当前版本。
5. 新进程启动失败或健康检查超时，尝试恢复上一个运行版本，并将本次任务标记失败。

服务替换期间会短暂停机。业务进程启动命令必须使用 `exec`，不能自行守护化。运行目录与临时构建目录分离，构建目录清理不会删除正在使用的运行文件。

| runtime 字段 | 说明 |
| --- | --- |
| `artifact` | 要运行的产物名称，必须在 artifacts 中声明 |
| `cwd` | 解压目录中的相对工作目录，默认 `.`；tar 包保留原项目相对路径 |
| `run` | 前台启动命令，例如 `exec java -jar backend/target/app.jar` |
| `healthcheck_url` | 必填，本容器 loopback HTTP(S) 地址，收到 2xx 才算就绪 |
| `start_timeout_seconds` | 启动就绪上限，默认 60 秒，受任务剩余时间限制 |
| `stop_timeout_seconds` | 先发 TERM，超过上限发 KILL，默认 20 秒 |

恢复旧版本允许另用一次启动超时，优先恢复服务。若恢复失败，日志会明确记录 `runtime.rollback_failed`，容器健康状态异常；需要检查业务配置或再次触发构建。

Spring Boot 服务示例：

```sh
cp examples/java-runtime.json pipeline.json
# 准备 secrets/application-runtime.yml，填写实际数据库、Redis 等运行配置。
# 如服务端口或健康端点不同，修改 pipeline.json 和 Compose override。
docker compose -f docker-compose.yml -f examples/compose.backend.yml up -d --build
```

[compose.backend.yml](examples/compose.backend.yml) 将业务端口 8080 单独映射到宿主机，Webhook 仍使用 9000。运行配置从 `/config/application-runtime.yml` 读取；示例健康检查使用 `/actuator/health`，部署前须确认该端点已启用并可访问。数据库、Redis 等依赖服务需另行提供。普通 Java 或 Node 服务可改为自己的前台启动命令和健康端点，不依赖 Spring Boot。

容器重启后自动启动 `/data/runtime/current.json` 记录的版本，不需要重新构建。运行中业务进程意外退出会发送 `runtime.failed` 并退出构建器，由 Compose 的 `restart: unless-stopped` 重启容器；当时正在执行的构建会标记中断。当前和上一个运行目录会保留。运行日志在 `/data/runtime/service.log`，单文件约 5 MiB，轮转保留一份。

runtime 进程可以读取 `BUILD_ID`、`BUILD_SHA`、`BUILD_REF`、`BUILD_RELEASE_DIR` 及容器配置的业务环境变量。构建器与业务服务共享容器资源，按峰值构建和业务运行需求配置内存。

## Apprise curl 通知

构建器通过 curl 调用独立部署的 [Apprise API](https://github.com/caronc/apprise-api)，不调用 Apprise CLI。推荐在 Apprise 中预存渠道配置，设置完整 `APPRISE_NOTIFY_URL=https://通知服务/notify/<KEY>`。`KEY` 是配置标识，不代替外部网关的访问认证。

可选 `APPRISE_TAG` 选择默认渠道；`APPRISE_AUTHORIZATION` 配置外部网关要求的完整 Authorization 值。URL 留空关闭通知。通知使用有状态 `/notify/<KEY>` 接口，渠道地址在 Apprise 服务端配置。

| 事件 | 默认发送 |
| --- | --- |
| `queued`、`started` | 是 |
| `checkout.succeeded` | 否 |
| `step.started`、`step.succeeded` | 否 |
| `artifacts.succeeded` | 否 |
| `after_build.started`、`after_build.succeeded` | 否 |
| `runtime.started`、`runtime.failed` | 是 |
| `succeeded`、`failed`、`timed_out`、`interrupted` | 是 |

每个事件可设置 `enabled`、`title`、`body`、`tag`。模板变量为 `{project}`、`{job_id}`、`{ref}`、`{sha}`、`{event}`、`{step}`、`{status}`、`{error}`、`{artifact_dir}`、`{duration_seconds}`、`{time}`，只做文字替换，不执行模板代码。

默认正文只显示该阶段已有的信息，排队消息不显示尚未产生的步骤、耗时、产物和错误。自定义 `body` 仍按原样替换变量，应按事件选择已有字段。

例如，只在最终成功或失败时通知：

```json
"notifications": {
  "queued": { "enabled": false },
  "started": { "enabled": false },
  "runtime.started": { "enabled": false },
  "succeeded": { "enabled": true },
  "failed": { "enabled": true },
  "timed_out": { "enabled": true },
  "interrupted": { "enabled": true },
  "runtime.failed": { "enabled": true }
}
```

其余阶段默认关闭；若已有配置显式开启了 `step.started` 等事件，也需将其设为 `false`。只收失败消息时再关闭 `succeeded`；只收成功消息时关闭上例中的四类失败事件。修改配置后等当前构建结束，再重建构建容器使其加载配置。

通知按顺序异步发送，不阻塞构建和入队。连接超时 5 秒、请求上限 15 秒，网络错误、429 和 5xx 最多额外重试一次。只有 HTTP 200 算发送成功，204（无有效渠道配置）记录为失败。网络重试可能产生重复消息。

通知失败记录 `notification.failed`，不修改构建结果。通知发送队列不持久化，容器强制退出可能丢失未发送消息；阶段事件文件仍可查询。通知不包含命令输出全文。Token 等已知敏感环境变量会做日志脱敏，但业务脚本仍须避免打印其他凭据。

## Git 凭据与文件挂载

镜像以 UID/GID `1000:1000` 运行。私有仓库可挂载 `./secrets/ssh:/home/node/.ssh:ro`，目录必须对该用户可读，私钥权限为 600；写好 `config` 和核验过的 `known_hosts`。不会关闭 SSH 主机密钥校验、修改只读凭据或要求 Git 用户邮箱。

HTTPS 仓库通过只读挂载的 `.netrc` 或受信任 Git credential helper 获取凭据，不要把密码嵌入 URL。部署 SSH 凭据与 Git 只读凭据建议使用不同 Host 别名和密钥。可信项目执行的构建脚本可以访问授予容器的凭据，因此不要接入外部不可信 PR。

| 路径 | 内容 |
| --- | --- |
| `/config/pipeline.json` | 只读项目配置 |
| `/data/jobs` | 持久化任务记录 |
| `/data/work` | 当前任务的独立检出目录，结束后清理 |
| `/data/cache` | Maven/npm/pnpm 下载缓存 |
| `/data/logs` | 命令日志及阶段事件 JSONL |
| `/data/artifacts/<id>` | tar.gz 包和 manifest.json（提交、架构、工具版本、校验和） |
| `/data/artifacts/latest-success` | 最近整体成功任务的相对软链接 |
| `/data/runtime` | 可选业务服务的当前版本记录、独立运行目录和日志 |

默认 Compose 使用命名卷。如换成宿主机目录，先为 UID 1000 准备可写目录。不要把源码工作目录或其他服务的数据挂成 `/data`。同一数据卷只能运行一个 Worker，第二个容器会因文件锁失败退出。

## 清理逻辑验证

在仓库根目录执行（使用 Node.js 内置测试，不需要额外依赖）：

```sh
node --test Docker/git-builder/tests/cleanup.test.mjs
```

测试仅在仓库 `tmp/` 下创建隔离数据，验证过期与数量限制、运行版本保护、缓存重置、符号链接边界和清理失败重试。

## 存储清理

容器启动时和每次任务结束后检查清理，不创建定时任务。清理完成后才开始下一个任务；成功、失败、超时及正常中断均触发检查，强制退出遗留的检出目录在下次启动时清理。没有构建或重启时，过期历史暂时保留。

```json
{
  "keep_runs": 5,
  "keep_days": 15,
  "cache_max_mb": 4096
}
```

上述配置清理最近 5 次以外或结束时间超过 15 天的任务，连同其产物、任务记录、命令日志和事件日志一起删除。排队中和运行中的任务不清理；当前、上一运行版本和 `latest-success` 指向的任务受到保护，因此实际数量可能超过 `keep_runs`。运行目录仍由发布流程保留当前及上一版本。任务记录清理后，相同 delivery ID 不再有持久化去重记录，人工重投旧事件可能再次构建。

仅统计 `/data/cache/maven`、`npm`、`pnpm`，超限后在构建空闲阶段重置这三个目录，不按缓存文件时间逐个删除。下一次构建需要重新下载依赖；阈值不是构建期间的磁盘配额。业务启动命令不应依赖这些下载缓存，应使用完整的运行产物。统计日志中的 `freed_bytes` 为文件逻辑大小，不代表文件系统实际释放空间（硬链接和压缩会影响实际用量）。

`cleanup.succeeded` 记录清理任务数、文件大小和缓存是否重置，不发送通知；`cleanup.failed` 记录错误，保留下次检查重试，不改变任务结果。业务自行写入的日志、备份、上传文件、其他缓存和宿主机 Docker 镜像不在清理范围内。

Compose 示例使用 `local` 日志驱动，单文件 10 MiB、保留 3 份。修改日志配置后需重建容器，单纯 restart 不生效。image 中的运行日志仍采用约 5 MiB、保留一份旧日志的轮转方式。

## 状态与恢复

```sh
docker compose exec git-builder node /app/service.mjs health
docker compose exec git-builder node /app/service.mjs status
docker compose exec git-builder node /app/service.mjs status <任务id>
docker compose exec git-builder cat /data/logs/<任务id>.log
docker compose cp git-builder:/data/artifacts/<任务id> ./release
```

健康检查验证 Worker 与其启动的 Webhook 进程。外部只暴露构建入口，不提供无认证日志或产物下载接口。

普通停止会终止当前任务进程组并标记 interrupted。重启后恢复 queued 任务，将上次遗留的 running 标记 interrupted，清理遗留检出目录，不自动重跑可能已经执行过的部署操作。每次任务 fetch 精确 SHA，取不到即失败，不回退到最新分支；默认不拉子模块或 Git LFS，需要时在受信任 steps 中显式配置。

## 构建、检查与发布

```sh
# 当前架构构建和工具链冒烟
docker build -t funnyzak/git-builder:dev .
docker run --rm funnyzak/git-builder:dev sh -ec 'node -v; npm -v; pnpm -v; java -version; mvn -v; webhook -version'

# 双架构发布
docker buildx build --platform linux/amd64,linux/arm64 \
  -t funnyzak/git-builder:1.0.0 --push .
docker buildx imagetools inspect funnyzak/git-builder:1.0.0
```

通过 GitHub Actions 发布时，在 **Release Choice Image** 中选择 `git-builder`，默认构建 AMD64 和 ARM64 镜像。Dockerfile、app、scripts 或 `.dockerignore` 修改会触发 nightly 构建；镜像仓库凭据通过 Actions secrets 配置。

验证范围包括工具版本、三种认证成功/失败、精确提交、连续投递串行化、重复 delivery 去重、非允许 ref 忽略、构建失败、超时、归档和 after_build 失败、Apprise HTTP 200/204/500、运行版本替换、失败恢复及容器重启恢复。检查脚本可运行 `shellcheck scripts/*.sh examples/*.sh`。真实业务配置和部署目标需要单独验证。

## 开源组件

- [adnanh/webhook](https://github.com/adnanh/webhook)：MIT，负责 HTTP 入口和认证规则。
- [Node.js Docker](https://github.com/nodejs/docker-node)、[Eclipse Temurin](https://github.com/adoptium/containers)、[Maven Docker](https://github.com/carlossg/docker-maven)：构建环境，沿用各上游许可。
- [Apprise API](https://github.com/caronc/apprise-api)：独立通知服务，不打包进本镜像。
