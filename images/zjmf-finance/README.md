# ZJMF Finance

这是可直接放进 GitHub 仓库的结构版本。

已处理：
- 镜像名统一为 `zjmf-finance`
- workflow 不再依赖 `images/_base`
- 启动自动修复 `/tmp/session` 为 `777`
- 使用 `supervisord` 保活 `php-fpm`、`nginx`、定时任务
- 默认每 1 分钟执行一次 `cd /var/www/html && php think cron`
