### 924 for build image

recently,I found that build image almost failed eachtime, and some buildpack‘behavior
 not so consistency(eg: they may 'toggle' passed or not when re-run build image)

> It seems that the builder crushed when it try to bind volume to buildpack ,cause of there was multi-version of cached jdk and syft in the volume, here is the files list in my proxy-volume,when I remove lower(or discarded) version ,I can build image successfully everytime。I'm wondering what you will do to solve this issue ? add some description in docs guides / add validation in buildpack / or just do nothing ,please leave a comment.


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


```shell
# pack war
mvn clean package
# run three times and save log to log/nbg-pack*.log
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
    --path target/paketo-demo-0.0.1-SNAPSHOT.war > ./issues/914/nbg-pack1.log
# run three times and save log to log/nbg-sb*.log
mvn install -P paketo -l ./issues/914/nbg-sb1.log
```