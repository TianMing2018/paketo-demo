# paketo-demo

a sample repo about how to use paketo build spring-boot app image,add some customized item for chinese language

## issues

here is some issues in practice

| brief                          | link                                                            | chapter   | fixed |
| ------------------------------ | --------------------------------------------------------------- | --------- | ----- |
| build image un-idempotency     | <https://github.com/paketo-buildpacks/java/issues/914>          | ### 924   | no    |
| health-checker loss thc client | <https://github.com/paketo-buildpacks/health-checker/issues/24> | ### 24 .. | yes   |
| support for chinese locale     | <https://github.com/paketo-buildpacks/base-builder/issues/659>  | ### 659.. | no    |


> those issues'log moved from `log/archive` to `issues`

## additional

### dive

dive is a tool for exploring each layer in a docker image, <https://github.com/wagoodman/dive/releases/> https://github.com/wagoodman/dive/releases/download/v0.10.0/dive_0.10.0_linux_amd64.deb

