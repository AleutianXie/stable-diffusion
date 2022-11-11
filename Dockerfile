FROM nvidia/cuda:11.4.1-base-ubuntu20.04
MAINTAINER Aleutian Xie<huisheng.xie@freshape.com>

ENV DEBIAN_FRONTEND=noninteractive

# update apt sources to aliyun
# RUN sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list
# update apt sources to tsinghua
RUN sed -i s@/archive.ubuntu.com/@/mirrors.tuna.tsinghua.edu.cn/@g /etc/apt/sources.list
RUN apt-get clean && apt-get update

# change time zone
RUN echo "Asia/Shanghai" > /etc/timezone

# install wget
RUN apt-get -y install wget

# install conda
# Create a working directory
RUN mkdir -p /app/anaconda3
WORKDIR /app/anaconda3
RUN cd /app/anaconda3
RUN wget https://mirrors.tuna.tsinghua.edu.cn/anaconda/archive/Anaconda3-2022.10-Linux-x86_64.sh
RUN bash Anaconda3-2022.10-Linux-x86_64.sh -b
RUN echo "export PATH=\"/home/root/anaconda3/bin:$PATH\"" >> ~/.bashrc
RUN /bin/bash -c "source /root/.bashrc"
RUN conda --version
