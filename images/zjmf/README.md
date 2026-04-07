# ZJMF 镜像

该目录用于构建 ZJMF 运行环境镜像。

## 构建

```bash
docker build -f images/zjmf/Dockerfile -t ghcr.io/<owner>/image-forge/zjmf:latest .
```

## 本地编排

可以先使用示例编排文件：

```bash
cp images/zjmf/docker-compose.example.yml docker-compose.yml
docker compose build --no-cache
docker compose up -d --no-build
```

## 发布

GitHub Actions 会自动将该镜像发布到：

- `ghcr.io/<owner>/image-forge/zjmf`
- `docker.io/<dockerhub-user>/image-forge-zjmf`

仓库中需要提前配置以下 Secrets：

- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`

## 说明

- 宿主机源码目录应挂载到容器内的 `/var/www/html`
- 挂载目录应为 ZJMF 项目根目录
- `swoole_loader_73_nts.so` 位于 `images/zjmf/files/`，构建时会自动复制并启用
