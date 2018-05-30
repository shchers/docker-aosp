FROM kylemanna/aosp:7.0-nougat

MAINTAINER Sergey Shcherbakov <shchers@gmail.com>

RUN apt-get update -y
RUN apt-get install -y lunzip pigz
