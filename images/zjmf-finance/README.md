# ZJMF Finance

这是可直接放进 GitHub 仓库的镜像构建版本。

已处理：
- 镜像名统一为 `zjmf-finance`
- GitHub Actions 默认推送 `mengfox/zjmf-finance:latest`
- 启动自动修复 `/tmp/session` 为 `777`
- 使用 `supervisord` 保活 `php-fpm`、`nginx`、定时任务
- 默认每 15 分钟执行一次 `php /var/www/html/think cron`
- Swoole Loader 仅在二进制兼容当前 PHP 时才自动启用

如果你有正确的 `swoole_loader_73_nts.so`，放到 `files/` 目录后重新构建即可。
