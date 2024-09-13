### SpringBoot2.x版本镜像打包问题

由于换了新的电脑，重新搭建环境之后，对原 `SpringBoot 2.x`版本的项目通过 `paketo_buildpacks` 打包镜像时总是会报如下错误：

```shell
[creator]     ERROR: failed to initialize detector: open /cnb/buildpacks/paketo-buildpacks_java/10.7.0/buildpack.toml: no such file or directory
```

通过查看SpringBoot 仓库的Issue 以及Docker 的历史发布记录，找到了原因是由于Docker Engine升级到 `25.x`版本以后，使用了 `V1.44` 版本的API, 而 SpringBoot 2.x 版本的 `spring-boot-maven-plugin` 采用了 低于 1.44版本的API，所以会报错。

> * [Building images fails with Docker 25.0 when custom buildpacks are configured · Issue #39323 · spring-projects/spring-boot (github.com)](https://github.com/spring-projects/spring-boot/issues/39323)
> * [Docker Desktop release notes | Docker Docs](https://docs.docker.com/desktop/release-notes/)
> * [Docker Engine 25.0 release notes | Docker Docs](https://docs.docker.com/engine/release-notes/25.0/)
> * \[[Engine API version history | Docker Docs](https://docs.docker.com/reference/api/engine/version-history/#v141-api-changes)\]

由于SpringBoot 2.x版本已经停止维护,因此可以通过如下方式进行维护

* 项目基础技术栈整体升级为SpringBoot 3.1.9/ 3.2.3之后的版本
* 升级JDK版本为17+并将打包插件 `org.springframework.boot/spring-boot-maven` 升级为 3.1.9 或者 3.2.3之后的版本
* 降级Docker Engin版本为24.0.9，具体版本号参照上面的 Docker Desktop/Docker Engine的 发布记录。

#### 降级Docker Engine方法

下面给出我搭建及实测的环境具体信息：

* OS: `Ubuntu 22.04.4 LTS`
* JDK: `bellsoft-jdk11.0.24+9`
* MAVEN: `apache-maven-3.9.9`
* Docker Engine: `5:24.0.9-1~ubuntu.22.04~jammy`
* SpringBoot: `2.7.18`
* Buildpack: `paketobuildpacks/java:15.2.0`
* Demo: [https://github.com/TianMing2018/paketo-demo](https://github.com/TianMing2018/paketo-demo.git "paketo-demo")

下面给出具体的安装命令:

> 注意：
>
> - 重装Docker之后，需要重新修改配置文件开放2375端口
> - 建议先备份容器、数据及镜像，避免降级后数据丢失(本例场景下实测未丢失数据)

```shell
focal@focal:~/paketo-demo$ for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done
focal@focal:~/paketo-demo$ VERSION_STRING=5:24.0.9-1~ubuntu.22.04~jammy
focal@focal:~/paketo-demo$ sudo apt-get install docker-ce=$VERSION_STRING docker-ce-cli=$VERSION_STRING containerd.io docker-buildx-plugin docker-compose-plugin
```