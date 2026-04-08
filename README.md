# ZJMF Finance 镜像构建仓

这是已经整理好的镜像构建包，可直接上传到 GitHub / Gitea / GitLab 作为独立仓库使用。

## 默认构建结果

- Docker Hub：`mengfox/zjmf-finance:latest`
- GHCR：`ghcr.io/<你的 GitHub 用户名>/zjmf-finance:latest`

## 目录说明

- `images/zjmf-finance/Dockerfile`：镜像构建文件
- `images/zjmf-finance/files/`：启动脚本、PHP 配置、定时任务脚本
- `images/zjmf-finance/source/zjmf-finance-3.7.0.zip`：源码包
- `.github/workflows/build-zjmf-finance.yml`：GitHub Actions 自动构建推送

## 说明

这个版本已经处理：

- 镜像名统一为 `zjmf-finance`
- 容器启动时自动初始化源码到 `/var/www/html`
- 自动修复 `/tmp/session` 权限为 `777`
- 使用 `supervisord` 守护 `php-fpm`、`nginx`、定时任务
- 默认每 15 分钟执行一次 `php /var/www/html/think cron`
- Swoole Loader 改为“检测兼容才启用”，避免因错误的 ZTS/NTS 文件导致 PHP 启动告警

## Docker Hub Secrets

GitHub Actions 推送 Docker Hub 需要配置：

- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`

如果你后面拿到了正确的 `swoole_loader_73_nts.so`，直接放到 `images/zjmf-finance/files/` 目录里重新构建即可，构建时会优先启用它。
