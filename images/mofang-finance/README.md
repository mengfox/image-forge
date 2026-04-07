# 魔方财务系统镜像

该目录用于构建内置魔方财务系统 `3.7.0` 安装包的运行环境镜像。

## 构建

```bash
docker build -f images/mofang-finance/Dockerfile -t ghcr.io/<owner>/image-forge/mofang-finance:latest .
```

## 本地编排

可以先使用示例编排文件：

```bash
cp images/mofang-finance/docker-compose.example.yml docker-compose.yml
docker compose build --no-cache
docker compose up -d --no-build
```

默认会把宿主机 `./data/mofang-finance` 挂载到容器内 `/var/www/html`。如果该目录为空，容器首次启动时会自动把镜像内置的程序文件初始化进去。

## 说明

- 镜像默认已内置魔方财务系统 `3.7.0` 安装包源码。
- Web 根目录固定为 `/var/www/html/public`。
- 镜像默认启用 `ionCube Loader`。
- 镜像同时内置并启用 `swoole_loader_73_zts.so`。
- 按官方安装文档要求关闭 `opcache`。
- 适用于通过 Docker 或 1Panel 直接部署。
- 当前源码来源为本地归档：`9754261af8a5c98e06c6b5532c9e2bec1730174405^3.7.0.zip`。