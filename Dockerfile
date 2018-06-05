#
# Minimum Docker image to build Android AOSP
#
# As a base used sources from https://github.com/kylemanna/docker-aosp
#
FROM ubuntu:14.04

MAINTAINER Sergey Shcherbakov <shchers@gmail.com>

# /bin/sh points to Dash by default, reconfigure to use bash until Android
# build becomes POSIX compliant
RUN echo "dash dash/sh boolean false" | debconf-set-selections && \
    dpkg-reconfigure -p critical dash

# Keep the dependency list as short as reasonable
RUN apt-get update -y

RUN apt-get install -y bc bison bsdmainutils build-essential curl wget
RUN apt-get install -y flex g++-multilib gcc-multilib git gnupg gperf lib32ncurses5-dev
RUN apt-get install -y lib32readline-gplv2-dev lib32z1-dev libesd0-dev libncurses5-dev
RUN apt-get install -y libsdl1.2-dev libwxgtk2.8-dev libxml2-utils lzop openjdk-7-jdk
RUN apt-get install -y pngcrush schedtool xsltproc zip zlib1g-dev
RUN apt-get install -y python-networkx make gawk

RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD https://commondatastorage.googleapis.com/git-repo-downloads/repo /usr/local/bin/
RUN chmod 755 /usr/local/bin/*

# Install latest version of JDK
# See http://source.android.com/source/initializing.html#setting-up-a-linux-build-environment
WORKDIR /tmp

# All builds will be done by user aosp
RUN wget https://raw.githubusercontent.com/kylemanna/docker-aosp/7.0-nougat/gitconfig -O /root/.gitconfig

RUN mkdir -p /root/.ssh/
RUN wget https://raw.githubusercontent.com/kylemanna/docker-aosp/7.0-nougat/ssh_config -O /root/.ssh/config

# The persistent data will be in these two directories, everything else is
# considered to be ephemeral
VOLUME ["/tmp/ccache", "/aosp"]

# Improve rebuild performance by enabling compiler cache
ENV USE_CCACHE 1
ENV CCACHE_DIR /tmp/ccache

# Work in the build directory, repo is expected to be init'd here
WORKDIR /aosp

RUN wget https://raw.githubusercontent.com/kylemanna/docker-aosp/7.0-nougat/utils/docker_entrypoint.sh -O /root/docker_entrypoint.sh
RUN chmod a+x /root/docker_entrypoint.sh

ENTRYPOINT ["/root/docker_entrypoint.sh"]
