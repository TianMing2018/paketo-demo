### buildpack打包过程中的资源代理

通过buildpack打包镜像时需要下载jdk等各种资源,由于国内访问github等站点不太稳定，特此创建资源代理

需要注意的是不同的buildpack所需要的资源是不同的，需要先行查看资源版本信息及其sha信息，主要有以下几种方式

#### 查看资源版本

##### 通过查看buildpack的toml文件

TODO： 查看buildpack的 toml 文件

##### 运行pack打包命令

```shell
  ubuntu@DESKTOP-T0EV4J4:~/test/paketo-demo$ sudo pack build pack-demo \
    --verbose \
    --buildpack paketobuildpacks/java:8 \
    --buildpack paketobuildpacks/health-checker:1 \
    --builder paketobuildpacks/builder:base \
    --run-image paketobuildpacks/run:base-cnb \
    --volume proxy-volume:/platform/bindings/dependency-mapping:ro \
    --pull-policy if-not-present \
    --env BP_LOG_LEVEL=DEBUG \
    --env BP_JVM_TYPE=JDK \
    --env BP_JVM_VERSION=11 \
    --env BP_HEALTH_CHECKER_ENABLED=true \
    --env THC_PORT=8180 \
    --env THC_PATH="/actuator/health" \
    --env BPE_LANG=zh_CN.UTF-8 \
    --env BPE_LC_ALL=zh_CN.UTF-8 \
    --env LANG=zh_CN.UTF-8 \
    --env LC_ALL=zh_CN.UTF-8 \
    --path target/paketo-demo-0.0.1-SNAPSHOT.war > ./log/archive/nbg-pack.log
```


> buildpack 备忘
> \--buildpack paketo-buildpacks/java:8
> \--buildpack docker://gcr.io/paketo-buildpacks/health-checker:1

##### 运行maven打包命令

```shell
mvn clean install -P paketo | tee paketo-initial.log
```

> 搜索日志中的downloading关键字确定下载的文件,如果新版本不展示该关键字的话，那就搜索sha256,把平台对应的资源下载下来
>
> * sha256:d0bedc485d79f66fe20eb748c5944d52a1ed8a7b753bcb7a8953e7cc8bc7bdf2 stacks:\[\*\] uri:https://github.com/bell-sw/Liberica/releases/download/11.0.24+9/bellsoft-jdk11.0.24+9-linux-amd64.tar.gz version:11.0.24
> * sha256:70a448cd45d1dbc117770f934961cd9577c0c4404d34986824f8f593cae4aada stacks:\[io.buildpacks.stacks.bionic io.paketo.stacks.tiny \*\] uri:https://repo1.maven.org/maven2/org/springframework/cloud/spring-cloud-bindings/1.13.0/spring-cloud-bindings-1.13.0.jar version:1.13.0
> * sha256:6f1db88187677e6825cf8c93d5424376660ff1009742e338ab39e00d7c11676e stacks:\[\*\] uri:https://github.com/dmikusa/tiny-health-checker/releases/download/v0.29.0/thc-x86\_64-unknown-linux-musl version:0.29.0
> * sha256:6a1b8a734a0939799239ba067895a7bc5ad57ac73c91bb197bed4d1d1705fbb1 stacks:\[_\] uri:https://github.com/anchore/syft/releases/download/v0.105.1/syft\_0.105.1\_linux\_amd64.tar.gz version:0.105.1
>   sha256:500b886038ccd553559fe19914e1a502728cfeb8ee9d81f3db448b05e5a890ec stacks:\[_\]
> * uri:https://github.com/watchexec/watchexec/releases/download/v2.1.2/watchexec-2.1.2-x86\_64-unknown-linux-musl.tar.xz version:2.1.2

#### 创建资源代理目录卷

```shell
# 创建目录卷
focal@focal:~$ sudo docker volume create proxy-volume
focal@focal:~$ sudo docker run -dti --name proxy -v proxy-volume:/tmp/paketo   nginx

# 拷贝需要的资源
focal@focal:~$ sudo docker cp bellsoft-jdk11.0.24+9-linux-amd64.tar.gz proxy:/tmp/paketo
focal@focal:~$ sudo docker cp spring-cloud-bindings-1.13.0.jar proxy:/tmp/paketo
focal@focal:~$ sudo docker cp thc-x86_64-unknown-linux-musl proxy:/tmp/paketo
focal@focal:~$ sudo docker cp syft_0.105.1_linux_amd64.tar.gz proxy:/tmp/paketo
focal@focal:~$ sudo docker cp watchexec-2.1.2-x86_64-unknown-linux-musl.tar.xz proxy:/tmp/paketo

# 进入容器编辑目录资源映射
focal@focal:~$ sudo docker exec -it proxy bash

root@372b114d8354:/# cd /tmp/paketo/
root@372b114d8354:/tmp/paketo# mkdir bellsoft & mv bellsoft-jdk11.0.24+9-linux-amd64.tar.gz bellsoft
root@372b114d8354:/tmp/paketo# mkdir spring-cloud-bindings & mv spring-cloud-bindings-1.13.0.jar spring-cloud-bindings
root@372b114d8354:/tmp/paketo# mkdir -p thc/0.29.0 & mv thc-x86_64-unknown-linux-musl thc/0.29.0
root@372b114d8354:/tmp/paketo# mkdir syft & mv syft_0.105.1_linux_amd64.tar.gz syft
root@372b114d8354:/tmp/paketo# mkdir watchexec & mv watchexec-2.1.2-x86_64-unknown-linux-musl.tar.xz watchexec

root@372b114d8354:/tmp/paketo# echo 'dependency-mapping' > type
root@372b114d8354:/tmp/paketo# echo 'file:///platform/bindings/build/bellsoft/bellsoft-jdk11.0.24+9-linux-amd64.tar.gz' > d0bedc485d79f66fe20eb748c5944d52a1ed8a7b753bcb7a8953e7cc8bc7bdf2
echo 'file:///platform/bindings/build/spring-cloud-bindings/spring-cloud-bindings-1.13.0.jar' > 70a448cd45d1dbc117770f934961cd9577c0c4404d34986824f8f593cae4aada
echo 'file:///platform/bindings/build/thc/0.29.0/thc-x86_64-unknown-linux-musl' > 6f1db88187677e6825cf8c93d5424376660ff1009742e338ab39e00d7c11676e
echo 'file:///platform/bindings/build/syft/syft_0.105.1_linux_amd64.tar.gz' > 6a1b8a734a0939799239ba067895a7bc5ad57ac73c91bb197bed4d1d1705fbb1
echo 'file:///platform/bindings/build/watchexec/watchexec-2.1.2-x86_64-unknown-linux-musl.tar.xz' > 500b886038ccd553559fe19914e1a502728cfeb8ee9d81f3db448b05e5a890ec
```