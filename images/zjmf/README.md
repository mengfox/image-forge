# ZJMF 镜像

该目录用于构建内置 ZJMF-CBAP 10.4.6 源码的运行环境镜像。

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

默认会把宿主机 `./data/zjmf` 挂载到容器内 `/var/www/html`。
如果该目录为空，容器首次启动时会自动把镜像内置的 ZJMF 程序文件初始化进去。

## 自动发布

GitHub Actions 会自动将该镜像发布到：

- `ghcr.io/<owner>/image-forge/zjmf`
- `docker.io/<dockerhub-user>/zjmf`

仓库需要提前配置这些 Secrets：

- `GHCR_USERNAME`
- `GHCR_TOKEN`
- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`

说明：

- `GHCR_TOKEN` 需要具备 `write:packages` 权限
- 私有仓库通常还需要同时具备 `repo` 权限
- `DOCKERHUB_TOKEN` 请使用 Docker Hub Access Token，不要直接使用账号密码

## 更新日志

镜像变更记录见 [../../CHANGELOG.md](../../CHANGELOG.md) 中的 `zjmf` 条目。

## 说明

- 镜像默认已内置 ZJMF-CBAP `10.4.6` 程序源码
- 空目录挂载到 `/var/www/html` 时会在首次启动自动初始化
- 初始化只在目标目录为空时执行，不会覆盖已有站点文件
- `swoole_loader_73_zts.so` 位于 `images/zjmf/files/`，镜像会内置该文件，但默认不启用
- 当前基础镜像为 `php:7.3-fpm`，入口脚本会在非兼容环境下自动跳过 `swoole_loader`
- 镜像内置 `supervisord` 会自动托管四个任务：`cron.php`、`task.php`、`on_demand_cron.php`、`task_notice.php`