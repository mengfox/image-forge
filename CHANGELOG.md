# 更新日志

本仓库用于维护 `image-forge` 下的容器镜像与 1Panel 应用模板变更记录。

## 2026-04-10

### lskypro-v2

- 新增 `build-lskypro-v2.yml`，支持在 GitHub Actions 中构建并发布 `lskypro-v2` 镜像。
- 修复 `lskypro-v2` Dockerfile 中构建阶段与运行阶段 PHP 版本不一致的问题，避免扩展二进制不兼容。

## 2026-04-07

### zjmf

- 新增 `zjmf` 镜像目录、构建工作流和中文说明文档。
- 支持同时发布到 GHCR 与 Docker Hub。
- 镜像运行环境基于 `Nginx + PHP 7.3 FPM`，补齐 ZJMF 所需常用扩展。
- 集成 `ionCube Loader` 与 `swoole_loader_73_zts.so`，默认关闭 `swoole_loader`，避免不兼容环境导致进程崩溃。
- 镜像内置 `ZJMF-CBAP 10.4.6` 程序源码，并支持在挂载空目录时自动初始化到 `/var/www/html`。
- 新增 1Panel 本地应用模板“智简魔方业务管理系统v10”。
- 修复脚本文件 BOM/换行问题，解决 `exec format error`。
- 修复旧版 `swoole_loader_73_nts.so` 导致的 `php-fpm` 崩溃问题，统一切换到 `swoole_loader_73_zts.so`。
- 1Panel 安装流程改为仅预填数据库参数和后台目录，不再提前生成根目录 `config.php`，避免跳过官方安装步骤。
- 按真实项目结构修正安装模板来源，使用 `/public/install/config.php` 作为安装流程模板来源。
- 修复 1Panel 反向代理子路径下安装完成后后台地址错误的问题。
- 移除镜像入口中旧的 `config.php` 自动生成逻辑，避免与 1Panel 安装流程产生冲突。
- 将自动化任务收敛为镜像内置 `supervisord` 进程，1Panel 启动包装层不再重复注册。
- 镜像内置自动化任务扩展为四条：`cron.php`、`task.php`、`on_demand_cron.php`、`task_notice.php`。

### zjmf-finance

- 新增 `zjmf-finance` 镜像目录，内置 ZJMF 财务系统 `3.7.0` 安装包。
- 镜像运行环境基于 `Nginx + PHP 7.3 FPM`，补齐 `gd`、`mysqli`、`pdo_mysql`、`intl`、`gmp`、`zip` 等常用扩展。
- 集成 `ionCube Loader` 与 `swoole_loader_73_zts.so`，并按官方安装文档要求默认关闭 `opcache`。
- 支持在挂载空目录时自动把镜像内置源码初始化到 `/var/www/html`。
- 新增对应的 1Panel 本地应用模板“魔方财务系统”。
- 1Panel 启动包装脚本支持把数据库地址、端口、用户名、密码、数据库名和后台路径预填到官方安装页 `public/install.html`。
- 1Panel 初始化脚本只负责准备持久化目录，不修改基础镜像层，正式安装仍走官方安装流程。
- 新增 `build-zjmf-finance.yml`，支持把镜像自动发布到 GHCR 与 Docker Hub。
