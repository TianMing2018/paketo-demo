# paketo-demo


a sample repo about how to use paketo build spring-boot app image,add some customized item for chinese language

## additional

### dive

dive is a tool for exploring each layer in a docker image, <https://github.com/wagoodman/dive/releases/> https://github.com/wagoodman/dive/releases/download/v0.10.0/dive_0.10.0_linux_amd64.deb

## issues


here is some issue in practice

|brief|link|chapter|fixed|
|------|-------|---|-----|
|build image un-idempotency| <https://github.com/paketo-buildpacks/java/issues/914> | ### 924 |no|
| health-checker loss thc client| <https://github.com/paketo-buildpacks/health-checker/issues/24> | ### 24 ..|yes|
| support for chinese locale | <https://github.com/paketo-buildpacks/base-builder/issues/659> | ### 659..|no|

### 924 for build image

recently,I found that build image almost failed eachtime, and some buildpack‘behavior
 not so consistency(eg: they may 'toggle' passed or not when re-run build image)

> It seems that the builder crushed when it try to bind volume to buildpack ,cause of there was multi-version of cached jdk and syft in the volume, here is the files list in my proxy-volume,when I remove lower(or discarded) version ,I can build image successfully everytime。I'm wondering what you will do to solve this issue ? add some description in docs guides / add validation in buildpack / or just do nothing ,please leave a comment.

#### step and logs

```shell
# pack war
mvn clean package
# run three times and save log to nbg-pack*.log
sudo pack build pack-demo \
    --verbose \
    --buildpack paketobuildpacks/java:8 \
    --buildpack paketobuildpacks/health-checker:1 \
    --builder paketobuildpacks/builder:base \
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
    --path target/paketo-demo-0.0.1-SNAPSHOT.war > nbg-pack1.log
# run three times and save log to nbg-sb*.log
mvn install -P paketo -l nbg-sb1.log
```


### 24 for health-cheker

It should could use caches to load thc client when re-build image

> and the default value should worked when `THC_PORT` or `THC_PATH` not specified

#### setp and logs

All the test running in one machine and docker running all the time without restart(docker installed on my windows host),here is the maven information in ubuntu and windows

```shell

PS D:\code\myconfig\docker\portainer> mvn -v
Apache Maven 3.8.6 (84538c9988a25aec085021c365c560670ad80f63)
Maven home: C:\Software\apache-maven-3.8.6
Java version: 11.0.16.1, vendor: BellSoft, runtime: C:\Software\Java\jdk-11.0.16.1
Default locale: zh_CN, platform encoding: GBK
OS name: "windows 11", version: "10.0", arch: "amd64", family: "windows"


Welcome to Ubuntu 22.04.1 LTS (GNU/Linux 5.15.79.1-microsoft-standard-WSL2 x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

This message is shown once a day. To disable it please create the /home/ubuntu/.hushlogin file.
ubuntu@DESKTOP-T0EV4J4:~/test/paketo-demo$ mvn -v
Apache Maven 3.8.6 (84538c9988a25aec085021c365c560670ad80f63)
Maven home: /mnt/c/Software/apache-maven-3.8.6
Java version: 11.0.17, vendor: Ubuntu, runtime: /usr/lib/jvm/java-11-openjdk-amd64
Default locale: en, platform encoding: UTF-8
OS name: "linux", version: "5.15.79.1-microsoft-standard-wsl2", arch: "amd64", family: "unix"

```


##### sprig-boot-maven mode

we can see that only the first time will write thc client successfully. releated log files prefix with **sb-health**

https://github.com/dmikusa/tiny-health-checker/releases/download/v0.8.0/thc-x86_64-unknown-linux-musl
echo 'file:///platform/bindings/dependency-mapping/thc-x86_64-unknown-linux-musl' > sha256:d3940b0f347744f9c0ebdc827f46014964a9de45b0d60b20116f6a60bb849a8a



- build 1
  ```shell
  mvn clean install -P paketo -X -l sb-health1.log
  docker volume ls
  DRIVER    VOLUME NAME
  local     cache-paketo-demo.build
  local     cache-paketo-demo.launch
  local     proxy-volume
  dive paketo-demo:0.0.1-SNAPSHOT
  Filetree
  └── layers
      └── paketo-buildpacks_health-checker
          └── thc
              ├── bin
              │   └── thc
              └── env.launch
                  └── health-check
                      ├── THC_PATH.default
                      └── THC_PORT.default
  ```
- build 2
  ```shell
  mvn clean install -P paketo -X -l sb-health2.log
  docker volume ls
  DRIVER    VOLUME NAME
  local     cache-paketo-demo.build
  local     cache-paketo-demo.launch
  local     proxy-volume
  dive paketo-demo:0.0.1-SNAPSHOT
  Filetree
  └── layers
      └── paketo-buildpacks_health-checker
          └── thc
              └── env.launch
                  └── health-check
                      ├── THC_PATH.default
                      └── THC_PORT.default
  ```
- build 3
  ```shell
  mvn clean install -P paketo -X -l sb-health3.log
  docker volume ls
  DRIVER    VOLUME NAME
  local     cache-paketo-demo.build
  local     cache-paketo-demo.launch
  local     proxy-volume
  dive paketo-demo:0.0.1-SNAPSHOT
  Filetree
  └── layers
      └── paketo-buildpacks_health-checker
          └── thc
              └── env.launch
                  └── health-check
                      ├── THC_PATH.default
                      └── THC_PORT.default
  ```
- build 4
  ```shell
  mvn clean install -P paketo -X -l sb-health4.log
  docker volume ls
  DRIVER    VOLUME NAME
  local     cache-paketo-demo.build
  local     cache-paketo-demo.launch
  local     proxy-volume
  dive paketo-demo:0.0.1-SNAPSHOT
  Filetree
  └── layers
      └── paketo-buildpacks_health-checker
          └── thc
              └── env.launch
                  └── health-check
                      ├── THC_PATH.default
                      └── THC_PORT.default
  ```

after the test,I inspect the volume and repeat test again and I found that maybe the volume recreated everytime?
```shell
ubuntu@DESKTOP-T0EV4J4:~/test/paketo-demo$ docker volume inspect cache-paketo-demo.build
[
    {
        "CreatedAt": "2023-01-10T02:14:10Z",
        "Driver": "local",
        "Labels": null,
        "Mountpoint": "/var/lib/docker/volumes/cache-paketo-demo.build/_data",
        "Name": "cache-paketo-demo.build",
        "Options": null,
        "Scope": "local"
    }
]
mvn clean install -P paketo -X -l sb-health5.log
ubuntu@DESKTOP-T0EV4J4:~/test/paketo-demo$ docker volume inspect cache-paketo-demo.build
[
    {
        "CreatedAt": "2023-01-10T02:41:19Z",
        "Driver": "local",
        "Labels": null,
        "Mountpoint": "/var/lib/docker/volumes/cache-paketo-demo.build/_data",
        "Name": "cache-paketo-demo.build",
        "Options": null,
        "Scope": "local"
    }
]
# list volume and dive image
  docker volume ls
  DRIVER    VOLUME NAME
  local     cache-paketo-demo.build
  local     cache-paketo-demo.launch
  local     proxy-volume
  dive paketo-demo:0.0.1-SNAPSHOT
  Filetree
  └── layers
      └── paketo-buildpacks_health-checker
          └── thc
              └── env.launch
                  └── health-check
                      ├── THC_PATH.default
                      └── THC_PORT.default
```



#### pack build mode

I have adjust command like @scottfrederick's,releated log files prefix with **pack-health**


sudo pack build pack-demo \
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
    --path target/paketo-demo-0.0.1-SNAPSHOT.war > nbg-pack.log







https://hub.docker.com/r/dmikusa/paketo-buildpacks-health-checker
- build 1
  ```shell
  ubuntu@DESKTOP-T0EV4J4:~/test/paketo-demo$ sudo pack build pack-demo \
    --builder paketobuildpacks/builder:base \
    --buildpack paketo-buildpacks/java \
    --buildpack docker://gcr.io/paketo-buildpacks/health-checker \
    --volume proxy-volume:/platform/bindings/dependency-mapping:ro \
    --env BP_HEALTH_CHECKER_ENABLED=true \
    --env BP_LOG_LEVEL=DEBUG \
    --env BP_JVM_TYPE=JDK \
    --verbose \
    --env THC_PORT=8180 \
    --env THC_PATH="/actuator/health" \
    --path target/paketo-demo-0.0.1-SNAPSHOT.war > pack-health1.log

  ubuntu@DESKTOP-T0EV4J4:~/test/paketo-demo$ docker volume ls
  DRIVER    VOLUME NAME
  local     cache-paketo-demo.build
  local     cache-paketo-demo.launch
  local     pack-cache-library_pack-demo_latest-ad5cec6fc0ee.build
  local     pack-cache-library_pack-demo_latest-ad5cec6fc0ee.launch
  local     proxy-volume
  ubuntu@DESKTOP-T0EV4J4:~/test/paketo-demo$ dive paketo-demo:0.0.1-SNAPSHOT
    Filetree
    └── layers
        └── paketo-buildpacks_health-checker
            └── thc
                ├── bin
                │   └── thc
                └── env.launch
                    └── health-check
                        ├── THC_PATH.default
                        └── THC_PORT.default
  ```
- build 2
  ```shell
  ubuntu@DESKTOP-T0EV4J4:~/test/paketo-demo$ sudo pack build pack-demo \
    --builder paketobuildpacks/builder:base \
    --buildpack paketo-buildpacks/java \
    --buildpack docker://gcr.io/paketo-buildpacks/health-checker \
    --volume proxy-volume:/platform/bindings/dependency-mapping:ro \
    --env BP_HEALTH_CHECKER_ENABLED=true \
    --env BP_LOG_LEVEL=DEBUG \
    --env BP_JVM_TYPE=JDK \
    --verbose \
    --env THC_PORT=8180 \
    --env THC_PATH="/actuator/health" \
    --path target/paketo-demo-0.0.1-SNAPSHOT.war > pack-health2.log
  ubuntu@DESKTOP-T0EV4J4:~/test/paketo-demo$ docker volume ls
  DRIVER    VOLUME NAME
  local     cache-paketo-demo.build
  local     cache-paketo-demo.launch
  local     pack-cache-library_pack-demo_latest-ad5cec6fc0ee.build
  local     pack-cache-library_pack-demo_latest-ad5cec6fc0ee.launch
  local     proxy-volume
  ubuntu@DESKTOP-T0EV4J4:~/test/paketo-demo$ docker volume inspect pack-cache-library_pack-demo_latest-ad5cec6fc0ee.build
  [
      {
          "CreatedAt": "2023-01-10T02:56:39Z",
          "Driver": "local",
          "Labels": null,
          "Mountpoint": "/var/lib/docker/volumes/pack-cache-library_pack-demo_latest-ad5cec6fc0ee.build/_data",
          "Name": "pack-cache-library_pack-demo_latest-ad5cec6fc0ee.build",
          "Options": null,
          "Scope": "local"
      }
  ]
  ubuntu@DESKTOP-T0EV4J4:~/test/paketo-demo$ dive paketo-demo:0.0.1-SNAPSHOT
    Filetree
    └── layers
        └── paketo-buildpacks_health-checker
            └── thc
                └── env.launch
                    └── health-check
                        ├── THC_PATH.default
                        └── THC_PORT.default
  ```
- build 3
  ```shell
  ubuntu@DESKTOP-T0EV4J4:~/test/paketo-demo$ sudo pack build pack-demo \
    --builder paketobuildpacks/builder:base \
    --buildpack paketo-buildpacks/java \
    --buildpack docker://gcr.io/paketo-buildpacks/health-checker \
    --volume proxy-volume:/platform/bindings/dependency-mapping:ro \
    --env BP_HEALTH_CHECKER_ENABLED=true \
    --env BP_LOG_LEVEL=DEBUG \
    --env BP_JVM_TYPE=JDK \
    --verbose \
    --env THC_PORT=8180 \
    --env THC_PATH="/actuator/health" \
    --path target/paketo-demo-0.0.1-SNAPSHOT.war > pack-health3.log

  ubuntu@DESKTOP-T0EV4J4:~/test/paketo-demo$ docker volume ls
  DRIVER    VOLUME NAME
  local     cache-paketo-demo.build
  local     cache-paketo-demo.launch
  local     pack-cache-library_pack-demo_latest-ad5cec6fc0ee.build
  local     pack-cache-library_pack-demo_latest-ad5cec6fc0ee.launch
  local     proxy-volume
  ubuntu@DESKTOP-T0EV4J4:~/test/paketo-demo$ docker volume inspect pack-cache-library_pack-demo_latest-ad5cec6fc0ee.build
  [
      {
          "CreatedAt": "2023-01-10T03:01:21Z",
          "Driver": "local",
          "Labels": null,
          "Mountpoint": "/var/lib/docker/volumes/pack-cache-library_pack-demo_latest-ad5cec6fc0ee.build/_data",
          "Name": "pack-cache-library_pack-demo_latest-ad5cec6fc0ee.build",
          "Options": null,
          "Scope": "local"
      }
  ]
  ubuntu@DESKTOP-T0EV4J4:~/test/paketo-demo$ dive paketo-demo:0.0.1-SNAPSHOT
    Filetree
    └── layers
        └── paketo-buildpacks_health-checker
            └── thc
                └── env.launch
                    └── health-check
                        ├── THC_PATH.default
                        └── THC_PORT.default
  ```
- build 4
```shell
ubuntu@DESKTOP-T0EV4J4:~/test/paketo-demo$ sudo pack build pack-demo \
  --builder paketobuildpacks/builder:base \
  --buildpack paketo-buildpacks/java \
  --buildpack docker://gcr.io/paketo-buildpacks/health-checker \
  --volume proxy-volume:/platform/bindings/dependency-mapping:ro \
  --env BP_HEALTH_CHECKER_ENABLED=true \
  --env BP_LOG_LEVEL=DEBUG \
  --env BP_JVM_TYPE=JDK \
  --verbose \
  --env THC_PORT=8180 \
  --env THC_PATH="/actuator/health" \
  --path target/paketo-demo-0.0.1-SNAPSHOT.war > pack-health4.log
ubuntu@DESKTOP-T0EV4J4:~/test/paketo-demo$ docker volume ls
DRIVER    VOLUME NAME
local     cache-paketo-demo.build
local     cache-paketo-demo.launch
local     pack-cache-library_pack-demo_latest-ad5cec6fc0ee.build
local     pack-cache-library_pack-demo_latest-ad5cec6fc0ee.launch
local     proxy-volume
ubuntu@DESKTOP-T0EV4J4:~/test/paketo-demo$ docker volume inspect pack-cache-library_pack-demo_latest-ad5cec6fc0ee.build
[
    {
        "CreatedAt": "2023-01-10T03:04:59Z",
        "Driver": "local",
        "Labels": null,
        "Mountpoint": "/var/lib/docker/volumes/pack-cache-library_pack-demo_latest-ad5cec6fc0ee.build/_data",
        "Name": "pack-cache-library_pack-demo_latest-ad5cec6fc0ee.build",
        "Options": null,
        "Scope": "local"
    }
]
ubuntu@DESKTOP-T0EV4J4:~/test/paketo-demo$ dive paketo-demo:0.0.1-SNAPSHOT
    Filetree
    └── layers
        └── paketo-buildpacks_health-checker
            └── thc
                └── env.launch
                    └── health-check
                        ├── THC_PATH.default
                        └── THC_PORT.default
  ```

> it seems that the build process will not using settings in pom such as `buildCache.volume.name`,and `pack` itself don't have this setting too.


#### maybe another problem

it seems that defaut setting for health-checker not works as wish too

```shell
root@44b9838a71d3:/workspace# cat /layers/paketo-buildpacks_health-checker/thc/env.launch/health-check/THC_PATH.default
/actuator/health

root@44b9838a71d3:/workspace# cat /layers/paketo-buildpacks_health-checker/thc/env.launch/health-check/THC_PORT.default
8180

root@44b9838a71d3:/workspace# /layers/paketo-buildpacks_health-checker/thc/bin/thc
Error:
request error: http://localhost:8080/: Connection Failed: Connect error: Address not available (os error 99)

root@44b9838a71d3:/workspace# THC_PORT=8180 THC_PATH=/actuator/health/ /layers/paketo-buildpacks_health-checker/thc/bin/thc
```


### 659 for base-builder repo

I had customized a runImage to chage locale to zh_CN.UTF-8 ,however,those changes did't work as wish cause it seems still have  **messy code probles** in logs(print ???? )

> timezone issue has been solved(use wrong command)


#### step for issue

1. build runImage

```shell
docker build  -t docker.myserver.com:5000/tianming2019/run:cn .
```

2. build image

```shell
mvn clean install -P paketo -l build.log
```

> you can check build log  by **build.log**

3. run container

```shell
docker run -p 8180:8180 --name paketo-demo paketo-demo:0.0.1-SNAPSHOT

Setting Active Processor Count to 8
Calculating JVM memory based on 10582560K available memory
For more information on this calculation, see https://paketo.io/docs/reference/java-reference/#memory-calculator
Calculated JVM Memory Configuration: -XX:MaxDirectMemorySize=10M -Xmx9973003K -XX:MaxMetaspaceSize=97556K -XX:ReservedCodeCacheSize=240M -Xss1M (Total Memory: 10582560K, Thread Count: 250, Loaded Class Count: 14810, Headroom: 0%)
Enabling Java Native Memory Tracking
Adding 0 container CA certificates to JVM truststore
Spring Cloud Bindings Enabled
Picked up JAVA_TOOL_OPTIONS: -Djava.security.properties=/layers/paketo-buildpacks_bellsoft-liberica/java-security-properties/java-security.properties -XX:+ExitOnOutOfMemoryError -XX:ActiveProcessorCount=8 -XX:MaxDirectMemorySize=10M -Xmx9973003K -XX:MaxMetaspaceSize=97556K -XX:ReservedCodeCacheSize=240M -Xss1M -XX:+UnlockDiagnosticVMOptions -XX:NativeMemoryTracking=summary -XX:+PrintNMTStatistics -Dorg.springframework.cloud.bindings.boot.enable=true

  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::                (v2.7.6)

2023-01-05 14:44:18.773  INFO 1 --- [           main] com.example.demo.DemoApplication         : Starting DemoApplication v0.0.3-SNAPSHOT using Java 11.0.17 on a310bd5d4ac3 with PID 1 (/workspace/BOOT-INF/classes started by root in /workspace)
2023-01-05 14:44:18.781  INFO 1 --- [           main] com.example.demo.DemoApplication         : No active profile set, falling back to 1 default profile: "default"
2023-01-05 14:44:23.466  INFO 1 --- [           main] o.s.b.w.embedded.tomcat.TomcatWebServer  : Tomcat initialized with port(s): 8180 (http)
2023-01-05 14:44:23.505  INFO 1 --- [           main] o.apache.catalina.core.StandardService   : Starting service [Tomcat]
2023-01-05 14:44:23.506  INFO 1 --- [           main] org.apache.catalina.core.StandardEngine  : Starting Servlet engine: [Apache Tomcat/9.0.69]
2023-01-05 14:44:23.748  INFO 1 --- [           main] o.a.c.c.C.[Tomcat].[localhost].[/]       : Initializing Spring embedded WebApplicationContext
2023-01-05 14:44:23.749  INFO 1 --- [           main] w.s.c.ServletWebServerApplicationContext : Root WebApplicationContext: initialization completed in 4806 ms
2023-01-05 14:44:25.934  INFO 1 --- [           main] o.s.b.a.e.web.EndpointLinksResolver      : Exposing 14 endpoint(s) beneath base path '/actuator'
2023-01-05 14:44:26.202  INFO 1 --- [           main] o.s.b.w.embedded.tomcat.TomcatWebServer  : Tomcat started on port(s): 8180 (http) with context path ''
2023-01-05 14:44:26.278  INFO 1 --- [           main] com.example.demo.DemoApplication         : Started DemoApplication in 8.591 seconds (JVM running for 9.596)
2023-01-05 14:44:32.566  INFO 1 --- [nio-8180-exec-1] o.a.c.c.C.[Tomcat].[localhost].[/]       : Initializing Spring DispatcherServlet 'dispatcherServlet'
2023-01-05 14:44:32.568  INFO 1 --- [nio-8180-exec-1] o.s.web.servlet.DispatcherServlet        : Initializing Servlet 'dispatcherServlet'
2023-01-05 14:44:32.575  INFO 1 --- [nio-8180-exec-1] o.s.web.servlet.DispatcherServlet        : Completed initialization in 6 ms
```


4. request demo

```shell
curl http://localhost:8180/demo
你好

5. got errors


```log
?????
^C
```

6. someothers mappings

```shell
# actuator info endpoint
curl http://localhost:8180/actuator/info
{"build":{"encoding":{"reporting":"UTF-8","source":"UTF-8"},"author":"tianming2019","version":"0.0.3-SNAPSHOT","artifact":"demo","java":{"source":"11","target":"11"},"name":"demo","time":"2023-01-05T06:43:10.869Z","group":"com.example"}}

docker exec -it paketo-demo /bin/bash


# locale
LANG=
LANGUAGE=
LC_CTYPE="POSIX"
LC_NUMERIC="POSIX"
LC_TIME="POSIX"
LC_COLLATE="POSIX"
LC_MONETARY="POSIX"
LC_MESSAGES="POSIX"
LC_PAPER="POSIX"
LC_NAME="POSIX"
LC_ADDRESS="POSIX"
LC_TELEPHONE="POSIX"
LC_MEASUREMENT="POSIX"
LC_IDENTIFICATION="POSIX"
LC_ALL=

# locale -a
C
C.UTF-8
POSIX
zh_CN.utf8
zh_HK.utf8
zh_SG.utf8
zh_TW.utf8
```

