# 更新日志

本文档记录 `image-forge` 仓库中的重要变更。

## 2026-04-07

### zjmf

- 新增 `zjmf` 镜像目录、构建工作流与中文说明文档。
- 支持将镜像自动发布到 GHCR 与 Docker Hub。
- 运行环境统一为 `Nginx + PHP 7.3 FPM`，并补齐 ZJMF 安装所需常用扩展、ionCube 与 `swoole_loader_73_zts.so`。
- 镜像改为内置 `ZJMF-CBAP 10.4.6` 源码，空目录挂载到 `/var/www/html` 时会在首次启动自动初始化。
- 新增 `1panelstore/zjmf` 应用模板，应用名为“智简魔方业务管理系统v10”，适配 1Panel 安装与持久化目录初始化场景。
- 修复 `exec format error`，将入口脚本统一为无 BOM、LF 换行，并在镜像构建阶段增加换行与 BOM 清理。
- 修复 `php-fpm` 因 loader 崩溃导致的启动问题，`swoole_loader_73_zts.so` 现默认关闭，仅在显式设置 `ENABLE_SWOOLE_LOADER=1` 且 PHP 运行时为 ZTS 时才会启用。