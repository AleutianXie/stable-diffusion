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

# install wget, git
RUN apt-get -y install wget git

# install glib sm6 xrender1
RUN apt-get -y install libglib2.0-dev libsm6 libxrender1

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
RUN conda init bash
# conda change to tsinghua source
COPY .condarc /root/.condarc
# change pip to tsinghua source
COPY pip.conf /root/.pip/pip.conf

RUN cd /app
RUN git clone https://github.com/AleutianXie/stable-diffusion.git
WORKDIR /app/stable-diffusion

RUN conda env create -f environment.yaml
# Make RUN commands use the new environment:
RUN echo "conda activate ldm" >> /root/.bashrc
SHELL ["/bin/bash", "--login", "-c"]

RUN /root/anaconda3/envs/ldm/lib/python3.8/site-packages/pip install -e git+https://github.com/CompVis/taming-transformers.git@master#egg=taming-transformers
RUN /root/anaconda3/envs/ldm/lib/python3.8/site-packages/pip install -e git+https://github.com/openai/CLIP.git@main#egg=clip
RUN /root/anaconda3/envs/ldm/lib/python3.8/site-packages/pip install -e .
RUN wget https://freshape-xjp.oss-accelerate.aliyuncs.com/Download_data/model/dfu/sd-v1-1.ckpt

# Download hub ...
RUN python scripts/txt2img.py --prompt "a pretty girl" --plms --ckpt sd-v1-1.ckpt --skip_grid --n_samples 1 --n_iter 1 --ddim_steps 100