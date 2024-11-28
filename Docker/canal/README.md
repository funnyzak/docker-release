# Canal Docker

Canal 是阿里巴巴 MySQL 数据库 binlog 增量订阅&消费组件。

## Build

### canal-adapter

```bash
docker build \
  --build-arg VERSION="1.1.7" \
  --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
  --build-arg CANAL_NAME="adapter" \
  -t funnyzak/canal-adapter:1.1.7 ./canal-adapter

# BUild alpha version
docker build \
  --build-arg VERSION="1.1.8-alpha-3" \
  --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
  --build-arg CANAL_NAME="adapter" \
  -t funnyzak/canal-adapter:1.1.8-alpha-3 ./canal-adapter
```

### canal-admin

```bash
docker build \
  --build-arg VERSION="1.1.7" \
  --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
  --build-arg CANAL_NAME="admin" \
  -t funnyzak/canal-admin:1.1.7 ./canal-adapter

# BUild alpha version
docker build \
  --build-arg VERSION="1.1.8-alpha-3" \
  --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
  --build-arg CANAL_NAME="admin" \
  -t funnyzak/canal-admin:1.1.8-alpha-3 ./canal-adapter
```

### canal-deployer

```bash
docker build \
  --build-arg VERSION="1.1.7" \
  --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
  --build-arg CANAL_NAME="deployer" \
  -t funnyzak/canal-deployer:1.1.7 ./canal-adapter

# BUild alpha version
docker build \
  --build-arg VERSION="1.1.8-alpha-3" \
  --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
  --build-arg CANAL_NAME="deployer" \
  -t funnyzak/canal-deployer:1.1.8-alpha-3 ./canal-adapter
```

更多信息请参考 [Canal 官方仓库](https://github.com/alibaba/canal/releases)。