# paketo-demo


a sample repo about how to use paketo build spring-boot app image,add some customized item for chinese language

## issues


here is some issue in practice

|brief|link|chapter|
|------|-------|---|
| health-checker loss thc client| <https://github.com/paketo-buildpacks/health-checker/issues/24> | ### 24 ..|
| support for chinese locale | <https://github.com/paketo-buildpacks/base-builder/issues/659> | ### 659..|

### 24 for health-cheker

loss thc client when rebuild docker image

#### setp for issue

1. modify pom.xml

```xml
<!-- comment this line -->
<!-- <cleanCache>true</cleanCache> -->
```

2. run build image  twice

```shell
mvn clean install -P paketo -l health1.log
mvn clean install -P paketo -l health2.log
```

3. inspect container
```
docker run -dti -p 8180:8180 --name paketo-demo paketo-demo:0.0.1-SNAPSHOT
docker exec -it paketo-demo bash
root@abb52b61115c:/workspace# ls /layers/paketo-buildpacks_health-checker/thc
env.launch
```
> we can seen that loss bin directory which contains thc

4. elude porblem

revert step 1

```shell
mvn clean install -P paketo -l health3.log
docker run -dti -p 8180:8180 --name paketo-demo paketo-demo:0.0.1-SNAPSHOT
docker exec -it paketo-demo bash
root@44b9838a71d3:/workspace# ls /layers/paketo-buildpacks_health-checker/thc
bin  env.launch
```

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

