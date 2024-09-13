### 24 for health-cheker

It should could use caches to load thc client when re-build image

> and the default value should worked when `THC_PORT` or `THC_PATH` not specified


#### environmental information

> - All the test running in one `windows 11` machine, which installed docker and `wsl ubuntu`
>   - the docker running all the time without restart
>   - all the test means issue 24、659、914, not all issuses under `issues` folder

here is the maven information in ubuntu and windows

- docker
  - `Server: Docker/20.10.21 (linux)`
- wsl ubuntu

```shell
Welcome to Ubuntu 22.04.1 LTS (GNU/Linux 5.15.79.1-microsoft-standard-WSL2 x86_64)

* Documentation:  https://help.ubuntu.com
* Management:     https://landscape.canonical.com
* Support:        https://ubuntu.com/advantage

This message is shown once a day. To disable it please create the /home/ubuntu/.hushlogin file.
```

- mvn on windows

```shell
PS D:\code\myconfig\docker\portainer> mvn -v
Apache Maven 3.8.6 (84538c9988a25aec085021c365c560670ad80f63)
Maven home: C:\Software\apache-maven-3.8.6
Java version: 11.0.16.1, vendor: BellSoft, runtime: C:\Software\Java\jdk-11.0.16.1
Default locale: zh_CN, platform encoding: GBK
OS name: "windows 11", version: "10.0", arch: "amd64", family: "windows"
```

- mvn on linux

```shell
ubuntu@DESKTOP-T0EV4J4:~/test/paketo-demo$ mvn -v
Apache Maven 3.8.6 (84538c9988a25aec085021c365c560670ad80f63)
Maven home: /mnt/c/Software/apache-maven-3.8.6
Java version: 11.0.17, vendor: Ubuntu, runtime: /usr/lib/jvm/java-11-openjdk-amd64
Default locale: en, platform encoding: UTF-8
OS name: "linux", version: "5.15.79.1-microsoft-standard-wsl2", arch: "amd64", family: "unix"
```

#### step for issue

> - You should run below commands in project's root path


##### sprig-boot-maven mode

we can see that only the first time will write thc client successfully. releated log files prefix with **sb-health** under **./issues/24/** directory

https://github.com/dmikusa/tiny-health-checker/releases/download/v0.8.0/thc-x86_64-unknown-linux-musl
echo 'file:///platform/bindings/dependency-mapping/thc-x86_64-unknown-linux-musl' > sha256:d3940b0f347744f9c0ebdc827f46014964a9de45b0d60b20116f6a60bb849a8a



- build 1
  ```shell
  mvn clean install -P paketo -X -l ./issues/24/sb-health1.log
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
  mvn clean install -P paketo -X -l ./issues/24/sb-health2.log
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
  mvn clean install -P paketo -X -l ./issues/24/sb-health3.log
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
  mvn clean install -P paketo -X -l ./issues/24/sb-health4.log
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
mvn clean install -P paketo -X -l ./issues/24/sb-health5.log
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

I have adjust command like @scottfrederick's,releated log files prefix with **pack-health** under **./issues/24/** directory


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
    --path target/paketo-demo-0.0.1-SNAPSHOT.war > ./issues/24/nbg-pack.log







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
    --path target/paketo-demo-0.0.1-SNAPSHOT.war > ./issues/24/pack-health1.log

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
    --path target/paketo-demo-0.0.1-SNAPSHOT.war > ./issues/24/pack-health2.log
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
    --path target/paketo-demo-0.0.1-SNAPSHOT.war > ./issues/24/pack-health3.log

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
  --path target/paketo-demo-0.0.1-SNAPSHOT.war > ./issues/24/pack-health4.log
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