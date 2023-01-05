FROM ubuntu:bionic

LABEL io.buildpacks.stack.id="io.buildpacks.stacks.bionic"
ARG packages=' curl jq '
ARG package_args='--allow-downgrades --allow-remove-essential --allow-change-held-packages --no-install-recommends'

RUN  sed -i "s@http://.*archive.ubuntu.com@http://repo.huaweicloud.com@g" /etc/apt/sources.list && \
     sed -i "s@http://.*security.ubuntu.com@http://repo.huaweicloud.com@g" /etc/apt/sources.list 

RUN echo "Package: $packages\nPin: release c=multiverse\nPin-Priority: -1\n\nPackage: $packages\nPin: release c=restricted\nPin-Priority: -1\n" > /etc/apt/preferences

RUN echo "debconf debconf/frontend select noninteractive" | debconf-set-selections && \
  export DEBIAN_FRONTEND=noninteractive && \
  apt-get -y $package_args update && \
  apt-get -y $package_args upgrade && \
  apt-get -y $package_args install locales language-pack-zh-hans language-pack-zh-hant language-pack-zh-hans-base && \
  locale-gen zh_CN.UTF-8 && \
  # update-locale LANG=zh_CN.UTF-8 LANGUAGE=zh_CN.zh:en_US:en LC_ALL=zh_CN.UTF-8 && \
  echo -e "export LANG=zh_CN.UTF-8\nexport LANGUAGE=zh_CN.zh:en_US:en\nexport LC_ALL=zh_CN.UTF-8" >> /etc/profile && \
  apt-get -y $package_args install tzdata && \
  ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
  echo "Asia/Shanghai" > /etc/timezone && \
  apt-get -y $package_args install $packages && \
  find /usr/share/doc/*/* ! -name copyright | xargs rm -rf && \
  rm -rf \
    /usr/share/man/* /usr/share/info/* \
    /usr/share/groff/* /usr/share/lintian/* /usr/share/linda/* \
    /var/lib/apt/lists/* /tmp/* /etc/apt/preferences

# remove /etc/os-release first as the test framework does not follow symlinks
RUN rm /etc/os-release && cat /usr/lib/os-release | \
    sed -e 's#PRETTY_NAME=.*#PRETTY_NAME="Paketo Buildpacks Base Bionic"#' \
        -e 's#HOME_URL=.*#HOME_URL="https://github.com/paketo-buildpacks/bionic-base-stack"#' \
        -e 's#SUPPORT_URL=.*#SUPPORT_URL="https://github.com/paketo-buildpacks/bionic-base-stack/blob/main/README.md"#' \
        -e 's#BUG_REPORT_URL=.*#BUG_REPORT_URL="https://github.com/paketo-buildpacks/bionic-base-stack/issues/new"#' \
  > /etc/os-release && rm /usr/lib/os-release
