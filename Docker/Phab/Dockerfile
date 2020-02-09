FROM ubuntu:latest
RUN apt-get clean
RUN sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list
RUN sed -i s@/security.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y sudo
ADD install_ubuntu.sh /opt/phab/install/
EXPOSE 8080
EXPOSE 8022
EXPOSE 8433