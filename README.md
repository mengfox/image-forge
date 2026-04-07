# image-forge

统一管理和发布各类容器镜像的构建仓库。

## 当前镜像

- `zjmf`：智简魔方业务管理系统 v10
- `mofang-finance`：魔方财务系统 3.7.0

## 仓库结构

```text
image-forge/
  .github/
    workflows/
      build-zjmf.yml
      build-mofang-finance.yml

  images/
    zjmf/
      Dockerfile
      docker-compose.example.yml
      README.md
      files/

    mofang-finance/
      Dockerfile
      docker-compose.example.yml
      README.md
      files/
      source/

  CHANGELOG.md
```

## 命名规范

- 仓库名：`image-forge`
- 镜像目录：`images/<image-name>/`
- 工作流：`.github/workflows/build-<image-name>.yml`
- GHCR 镜像：`ghcr.io/<owner>/image-forge/<image-name>:<tag>`
- Docker Hub 镜像：`docker.io/<user>/<image-name>:<tag>`

## 发布说明

当前镜像通过 GitHub Actions 自动构建，并发布到：

- GitHub Container Registry
- Docker Hub

触发方式：

- 推送到 `main`
- 推送 `v*` 标签
- 手动触发 `workflow_dispatch`

## 更新日志

完整变更记录见 [CHANGELOG.md](./CHANGELOG.md)。

## 使用说明

具体镜像的构建方式、挂载方式和运行方式，请查看对应目录下的 `README.md`。