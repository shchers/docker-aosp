FROM kylemanna/aosp:5.0-lollipop

MAINTAINER Sergey Shcherbakov <shchers@gmail.com>

RUN apt-get update -y
RUN apt-get install -y python-networkx make gawk
