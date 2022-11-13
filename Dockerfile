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
WORKDIR /app
RUN cd /app/anaconda3
RUN wget https://mirrors.tuna.tsinghua.edu.cn/anaconda/archive/Anaconda3-2022.10-Linux-x86_64.sh
RUN bash Anaconda3-2022.10-Linux-x86_64.sh -b && \
    echo "export PATH=\"/root/anaconda3/bin:$PATH\"" >> ~/.bashrc && \
    /bin/bash -c "source /root/.bashrc"
ENV PATH /root/anaconda3/bin:$PATH
RUN conda --version
# conda change to tsinghua source
COPY .condarc /root/.condarc
RUN conda config --show-sources &&  \
    conda config --set show_channel_urls yes&& \
    conda config --set always_yes yes

# install git
RUN apt-get -y install git
RUN cd /app
RUN git clone https://github.com/AleutianXie/stable-diffusion.git
WORKDIR /app/stable-diffusion

RUN conda env create -f environment.yaml && \
    conda activate ldm
